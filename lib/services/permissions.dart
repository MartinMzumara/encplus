import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPermission(BuildContext context, Permission permission) async {
  final status = await permission.request();
  if (status == PermissionStatus.granted) {
    return true;
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text('Please grant permission to use this feature.'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
    return false;
  }
}
