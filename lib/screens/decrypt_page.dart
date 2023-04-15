import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

import '../components/custom_nav.dart';
import '../services/file_utils.dart';
import 'encrypt_page.dart';
import 'homepage.dart';
import 'settings_page.dart';

String? userPassword = 'FileEncryption';

class DecryptionPage extends StatefulWidget {
  @override
  _DecryptionPageState createState() => _DecryptionPageState();
}

class _DecryptionPageState extends State<DecryptionPage> {
  bool _isDecrypting = false;
  String _decryptedFilePath = '';
  File? _selectedFile;
  String _statusText = '';

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  void _decryptFile() async {
    // Show a loading indicator while the file is being decrypted

    if (_selectedFile == null) {
      setState(() {
        _statusText = 'Please select a file to encrypt.';
      });
      return;
    } else {
      setState(() {
        _isDecrypting = true;
      });
    }

    try {
      // Retrieve the AES encryption key from Firebase Cloud Functions
      final key = await _getEncryptionKey(userPassword!);

      // Read the encrypted file as bytes
      final encryptedData = await _readFileAsBytes(_selectedFile as String);

      // Split the encrypted file data into the initialization vector (first 16 bytes)
      // and the encrypted file content
      final iv = encryptedData.sublist(0, 16);
      final encryptedFileContent = encryptedData.sublist(16);

      // Decrypt the file content using the AES key and initialization vector
      final decryptedFileContent =
          decrypt(encryptedFileContent, key as Uint8List, iv);

      // Get the name of the decrypted file
      final decryptedFileName = _getDecryptedFileName(_selectedFile as String);

      // Save the decrypted file to the app's documents directory
      final decryptedFilePath =
          await _saveFile(decryptedFileName, decryptedFileContent);

      // Update the state with the path to the decrypted file
      setState(() {
        _decryptedFilePath = decryptedFilePath;
      });
    } on FileSystemException catch (e) {
      // Handle errors related to file I/O, such as file not found or permissions issues
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error accessing file: $e')));
    } on FormatException catch (e) {
      // Handle errors related to data formatting, such as incorrect password or corrupted data
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error decrypting file: $e')));
    } catch (e) {
      // Handle all other errors
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')));
    } finally {
      // Hide the loading indicator
      setState(() {
        _isDecrypting = false;
      });
    }
  }

  String _getDecryptedFileName(String filePath) {
// Extract the filename and extension from the encrypted file path
    final fileName = filePath.split('/').last;
    final fileExtension = fileName.split('.').last;
// Replace the extension with .decrypted
    return '${fileName.substring(0, fileName.length - fileExtension.length - 1)}.decrypted';
  }

  Future<Uint8List?> _getEncryptionKey(String password) async {
    Uint8List? loginPasswordBytes = utf8.encode(userPassword!) as Uint8List?;
    Uint8List? key = sha256.convert(loginPasswordBytes!).bytes as Uint8List?;
    return key;
  }

  Future<Uint8List> _readFileAsBytes(String filePath) async {
// Read the file as bytes
    final file = File(filePath);
    final fileContent = await file.readAsBytes();
    return fileContent;
  }

  Future<String> _saveFile(String fileName, Uint8List fileContent) async {
// Get the app's documents directory
    final documentsDirectory = await getApplicationDocumentsDirectory();
// Create a new file in the documents directory with the given file name
    final newFile = File('${documentsDirectory.path}/$fileName');

// Write the file content to the new file
    await newFile.writeAsBytes(fileContent);

// Return the path to the new file
    return newFile.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Decrypt File'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: _selectedFile == null
                    ? const Text('No file selected.')
                    : Text('Selected file: ${_selectedFile!.path}'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _selectFile,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Select File'),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _decryptFile,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Decrypt File'),
                ),
              ),
              const SizedBox(height: 24),
              if (_isDecrypting)
                CircularProgressIndicator()
              else if (_decryptedFilePath.isNotEmpty)
                Text('Decrypted file saved to $_decryptedFilePath'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock),
            label: 'Encrypt',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock_open),
            label: 'Decrypt',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings')
        ],
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EncryptionPage(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DecryptionPage(),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsPage(),
              ),
            );
          }
        },
      ),
    );
  }
}
