import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../providers/recording_provider.dart';
import '../models/recording_model.dart';

class PlaybackScreen extends StatefulWidget {
  const PlaybackScreen({Key? key}) : super(key: key);

  @override
  State<PlaybackScreen> createState() => _PlaybackScreenState();
}

class _PlaybackScreenState extends State<PlaybackScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  String? _currentPlayingId;

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer(String videoPath, String recordingId) async {
    if (_currentPlayingId == recordingId && _videoPlayerController != null) {
      // Already playing this video
      return;
    }
    
    // Dispose previous controllers
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    
    // Initialize new controllers
    _videoPlayerController = VideoPlayerController.file(File(videoPath));
    
    try {
      await _videoPlayerController!.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Error: $errorMessage',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );
      
      _currentPlayingId = recordingId;
      
      setState(() {});
    } catch (e) {
      debugPrint('Error initializing video player: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing video: $e')),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecordingProvider>(context);
    final recordings = provider.recordings;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordings'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade50, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Video player area
            if (_chewieController != null)
              Container(
                height: 250,
                color: Colors.black,
                child: Chewie(controller: _chewieController!),
              ),
            
            // Recordings list
            Expanded(
              child: recordings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No recordings yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Start recording to see your videos here',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: recordings.length,
                    itemBuilder: (context, index) {
                      final recording = recordings[index];
                      final isPlaying = _currentPlayingId == recording.id;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: isPlaying ? Colors.blue.shade50 : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isPlaying
                              ? BorderSide(color: Colors.blue.shade300, width: 2)
                              : BorderSide.none,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.video_file,
                              color: Colors.deepPurple,
                              size: 30,
                            ),
                          ),
                          title: Text(
                            'Recording ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                _formatDateTime(recording.recordedAt),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Duration: ${_formatDuration(recording.duration)}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  if (isPlaying && _videoPlayerController != null) {
                                    if (_videoPlayerController!.value.isPlaying) {
                                      _videoPlayerController!.pause();
                                    } else {
                                      _videoPlayerController!.play();
                                    }
                                    setState(() {});
                                  } else {
                                    _initializePlayer(recording.filePath, recording.id);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Delete Recording'),
                                        content: const Text(
                                          'Are you sure you want to delete this recording? '
                                          'This action cannot be undone.',
                                        ),
                                        actions: [
                                          TextButton(
                                            child: const Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                            onPressed: () async {
                                              if (isPlaying) {
                                                _videoPlayerController?.pause();
                                                _videoPlayerController?.dispose();
                                                _chewieController?.dispose();
                                                _videoPlayerController = null;
                                                _chewieController = null;
                                                _currentPlayingId = null;
                                              }
                                              
                                              await provider.deleteRecording(recording.id);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}