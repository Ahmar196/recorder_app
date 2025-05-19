import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recording_provider.dart';
import '../services/recording_service.dart';
import 'playback_screen.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({Key? key}) : super(key: key);

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final RecordingService _recordingService = RecordingService();
  Timer? _recordingTimer;
  Duration _elapsedTime = Duration.zero;
  final List<Duration> _durations = [
    const Duration(seconds: 15),
    const Duration(seconds: 30),
    const Duration(minutes: 1),
    const Duration(minutes: 2),
  ];

  @override
  void dispose() {
    _recordingTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Future<void> _startRecording() async {
    final provider = Provider.of<RecordingProvider>(context, listen: false);
    
    if (provider.isRecording) return;
    
    final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}';
    final filePath = await _recordingService.startRecording(fileName);
    
    if (filePath != null) {
      provider.startRecording(filePath);
      
      // Start the timer for UI update
      setState(() {
        _elapsedTime = Duration.zero;
      });
      
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _elapsedTime = Duration(seconds: timer.tick);
        });
        
        // Auto-stop recording if selected duration reached
        if (_elapsedTime >= provider.selectedDuration) {
          _stopRecording();
        }
      });
    }
  }

  Future<void> _stopRecording() async {
    final provider = Provider.of<RecordingProvider>(context, listen: false);
    
    if (!provider.isRecording) return;
    
    _recordingTimer?.cancel();
    _recordingTimer = null;
    
    final path = await _recordingService.stopRecording();
    if (path != null) {
      provider.stopRecording(_elapsedTime);
      setState(() {
        _elapsedTime = Duration.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecordingProvider>(context);
    final isRecording = provider.isRecording;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen Recorder'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.video_library),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlaybackScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade50, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          'Record Screen Activity',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Duration dropdown
                        if (!isRecording)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select Recording Duration:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<Duration>(
                                    isExpanded: true,
                                    value: provider.selectedDuration,
                                    items: _durations.map((duration) {
                                      String label = '';
                                      if (duration.inMinutes >= 1) {
                                        label = '${duration.inMinutes} ${duration.inMinutes == 1 ? 'minute' : 'minutes'}';
                                      } else {
                                        label = '${duration.inSeconds} seconds';
                                      }
                                      
                                      return DropdownMenuItem(
                                        value: duration,
                                        child: Text(label),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        provider.setSelectedDuration(value);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                        const SizedBox(height: 30),
                        
                        // Recording status and timer
                        if (isRecording)
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.5),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'RECORDING',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _formatDuration(_elapsedTime),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              LinearProgressIndicator(
                                value: _elapsedTime.inSeconds / provider.selectedDuration.inSeconds,
                                backgroundColor: Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Time remaining: ${_formatDuration(provider.selectedDuration - _elapsedTime)}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Record button
                ElevatedButton(
                  onPressed: isRecording ? _stopRecording : _startRecording,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: isRecording ? Colors.red : Colors.blue,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isRecording ? Icons.stop : Icons.fiber_manual_record),
                      const SizedBox(width: 8),
                      Text(isRecording ? 'Stop Recording' : 'Start Recording'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                if (!isRecording)
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PlaybackScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.playlist_play),
                        SizedBox(width: 8),
                        Text('View Recordings'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
