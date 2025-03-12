// ignore_for_file: avoid_print

import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ocr_plugin_macos/ocr_plugin_macos.dart';
import 'package:ocr_plugin_macos/ocr_result.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

const XTypeGroup typeGroup = XTypeGroup(
  label: 'images',
  extensions: <String>['jpg', 'png'],
);

class _MyAppState extends State<MyApp> {
  final _ocrPluginMacosPlugin = OcrPluginMacos();

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> ocrImage() async {
    final XFile? file = await openFile(
      acceptedTypeGroups: <XTypeGroup>[typeGroup],
    );
    if (file == null) {
      print('No file selected');
      return;
    }

    File f = File(file.path);
    print("file exists : ${f.existsSync()}");

    List<OcrResult> results = [];
    try {
      results = await _ocrPluginMacosPlugin.recognizeText(file.path);
      print("results: $results");
      for (var result in results) {
        print(result);
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: TextButton(
            onPressed: () {
              ocrImage();
            },
            child: Text("test"),
          ),
        ),
      ),
    );
  }
}
