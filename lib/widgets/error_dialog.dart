import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({required this.content, super.key});

  final String content;

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid ? _showAndroidDialog(context) : _showIOSDialog(context);
  }

  AlertDialog _showAndroidDialog (BuildContext context){
    return AlertDialog(title: const Text('Error'), content: Text(content), actions: [
      ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Ok'))
    ],);
  }

  CupertinoAlertDialog _showIOSDialog(BuildContext context){
    return CupertinoAlertDialog(title: const Text('Error'), content: Text(content),
    actions: [
      CupertinoDialogAction(child: const Text('Ok'), onPressed: () => Navigator.of(context).pop())
    ],);
  }
}