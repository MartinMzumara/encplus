import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import '../components/custom_nav.dart';
import '../services/file_utils.dart';
import 'decrypt_page.dart';
import 'homepage.dart';
import 'settings_page.dart';

final String loginPassword = 'FileEncryption';

class EncryptionPage extends StatefulWidget {
  @override
  _EncryptionPageState createState() => _EncryptionPageState();
}

class _EncryptionPageState extends State<EncryptionPage> {
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

  Future<void> _encryptFile() async {
    if (_selectedFile == null) {
      setState(() {
        _statusText = 'Please select a file to encrypt.';
      });
      return;
    }

    try {
      // Read the contents of the selected file.
      Uint8List fileContents = await _selectedFile!.readAsBytes();

      // Generate an encryption key from the user's login password.
      Uint8List? loginPasswordBytes = utf8.encode(loginPassword) as Uint8List?;
      Uint8List? key = sha256.convert(loginPasswordBytes!).bytes as Uint8List?;

      // Generate an IV for AES encryption.
      Uint8List iv = generateIV();

      // Encrypt the file contents.
      Uint8List encryptedContents = encrypt(fileContents, key!, iv);

      // Save the encrypted file to a new file.
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String encryptedFilePath = path.join(
          appDocDir.path, 'encrypted_${_selectedFile!.path.split('/').last}');
      File encryptedFile = File(encryptedFilePath);
      await encryptedFile.writeAsBytes(encryptedContents);

      setState(() {
        _statusText = 'File encrypted successfully.';
      });
    } catch (e) {
      setState(() {
        _statusText = 'Error encrypting file: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Encryption'),
      ),
      body: Padding(
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
              onPressed: _encryptFile,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Encrypt File'),
              ),
            ),
            const SizedBox(height: 16),
            Text(_statusText),
          ],
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
        currentIndex: 1,
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
