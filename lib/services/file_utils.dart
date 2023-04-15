import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

import 'package:crypto/crypto.dart';

/// Generates a random initialization vector for AES encryption.
Uint8List generateIV() {
  final random = SecureRandom('AES/CTR/AUTO-SEED-PRNG')
    ..seed(KeyParameter(Uint8List.fromList(
        DateTime.now().microsecondsSinceEpoch.toRadixString(16).codeUnits)));

  final iv = Uint8List(16);
  random.nextBytes(iv as int);

  return iv;
}

Uint8List generateKeyFromPassword(String password, Uint8List salt) {
  // Number of iterations for PBKDF2
  const iterations = 10000;
  // Length of the derived key in bytes
  const keyLength = 32;

  // Convert the password to UTF-8 bytes
  final passwordBytes = utf8.encode(password);

  // Generate the key using PBKDF2
  final pbkdf2 =
      PBKDF2KeyDerivator(Hmac(SHA256Digest() as Hash, passwordBytes) as Mac);
  pbkdf2.init(Pbkdf2Parameters(salt, iterations, keyLength));
  return pbkdf2.process(passwordBytes as Uint8List);
}

/// Encrypts a [Uint8List] using AES encryption with the given [key] and [iv].
Uint8List encrypt(Uint8List data, Uint8List key, Uint8List iv) {
  final cipher = _getAESCipher(true, key, iv);
  final encrypted = cipher.process(data);
  cipher.reset();
  return encrypted;
}

/// Decrypts a [Uint8List] using AES decryption with the given [key] and [iv].
Uint8List decrypt(Uint8List data, Uint8List key, Uint8List iv) {
  final cipher = _getAESCipher(false, key, iv);
  final decrypted = cipher.process(data);
  cipher.reset();
  return decrypted;
}

/// Returns an instance of an AES cipher with the specified [mode], [key], and [iv].
CipherParameters _getCipherParameters(Uint8List key, Uint8List iv) {
  final keyParam = KeyParameter(key);
  final ivParam = ParametersWithIV(keyParam, iv);
  return ivParam;
}

/// Returns an AES cipher with the specified [mode], [key], and [iv].
BlockCipher _getAESCipher(bool forEncryption, Uint8List key, Uint8List iv) {
  final params = _getCipherParameters(key, iv);
  final cipher = AESEngine()..init(forEncryption, params as KeyParameter);

  return cipher;
}
