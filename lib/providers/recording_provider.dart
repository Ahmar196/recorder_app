import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/recording_model.dart';

class RecordingProvider extends ChangeNotifier {
  List<Recording> _recordings = [];
  bool _isRecording = false;
  DateTime? _recordingStartTime;
  String? _currentRecordingPath;
  Duration _selectedDuration = const Duration(seconds: 15);

  List<Recording> get recordings => _recordings;
  bool get isRecording => _isRecording;
  DateTime? get recordingStartTime => _recordingStartTime;
  Duration get selectedDuration => _selectedDuration;
  String? get currentRecordingPath => _currentRecordingPath;

  RecordingProvider() {
    _loadRecordings();
  }

  void setSelectedDuration(Duration duration) {
    _selectedDuration = duration;
    notifyListeners();
  }

  void startRecording(String filePath) {
    _isRecording = true;
    _recordingStartTime = DateTime.now();
    _currentRecordingPath = filePath;
    notifyListeners();
  }

  void stopRecording(Duration actualDuration) {
    if (!_isRecording) return;

    final newRecording = Recording(
      id: const Uuid().v4(),
      filePath: _currentRecordingPath!,
      recordedAt: _recordingStartTime!,
      duration: actualDuration,
    );

    _recordings.add(newRecording);
    _isRecording = false;
    _recordingStartTime = null;
    _currentRecordingPath = null;
    
    _saveRecordings();
    notifyListeners();
  }

  Future<void> _loadRecordings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordingsString = prefs.getStringList('recordings') ?? [];
      
      _recordings = recordingsString.map((recordingStr) {
        final map = json.decode(recordingStr) as Map<String, dynamic>;
        return Recording.fromMap(map);
      }).toList();
      
      // Filter out recordings whose files no longer exist
      _recordings = _recordings.where((recording) {
        final file = File(recording.filePath);
        return file.existsSync();
      }).toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading recordings: $e');
    }
  }

  Future<void> _saveRecordings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordingStrings = _recordings.map((recording) {
        return json.encode(recording.toMap());
      }).toList();
      
      await prefs.setStringList('recordings', recordingStrings);
    } catch (e) {
      debugPrint('Error saving recordings: $e');
    }
  }

  Future<void> deleteRecording(String id) async {
    try {
      final recordingIndex = _recordings.indexWhere((rec) => rec.id == id);
      if (recordingIndex >= 0) {
        final recording = _recordings[recordingIndex];
        final file = File(recording.filePath);
        
        if (await file.exists()) {
          await file.delete();
        }
        
        _recordings.removeAt(recordingIndex);
        await _saveRecordings();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting recording: $e');
    }
  }
}