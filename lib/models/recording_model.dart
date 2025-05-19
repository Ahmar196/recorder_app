import 'dart:io';

class Recording {
  final String id;
  final String filePath;
  final DateTime recordedAt;
  final Duration duration;

  Recording({
    required this.id,
    required this.filePath,
    required this.recordedAt, 
    required this.duration,
  });

  // Convert the model to a map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filePath': filePath,
      'recordedAt': recordedAt.millisecondsSinceEpoch,
      'duration': duration.inSeconds,
    };
  }

  // Create a Recording from a map
  factory Recording.fromMap(Map<String, dynamic> map) {
    return Recording(
      id: map['id'],
      filePath: map['filePath'],
      recordedAt: DateTime.fromMillisecondsSinceEpoch(map['recordedAt']),
      duration: Duration(seconds: map['duration']),
    );
  }
}
