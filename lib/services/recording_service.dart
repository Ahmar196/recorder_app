import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordingService {
  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.microphone,
    ].request();
    
    return statuses.values.every((status) => status.isGranted);
  }

  Future<String?> startRecording(String fileName) async {
    try {
      bool hasPermissions = await requestPermissions();
      if (!hasPermissions) {
        throw Exception('Permissions not granted');
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.mp4';
      
      // Start recording with the FlutterScreenRecording plugin
      await FlutterScreenRecording.startRecordScreen(
        fileName,
        titleNotification: "Recording screen",
        messageNotification: "Recording in progress",
      );
      
      return filePath;
    } catch (e) {
      debugPrint('Error starting recording: $e');
      return null;
    }
  }

  Future<String?> stopRecording() async {
    try {
      final path = await FlutterScreenRecording.stopRecordScreen;
      return path;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      return null;
    }
  }
}
