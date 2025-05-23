# screen_recorder

Features
📱 Recording Screen

Select recording duration from multiple options (15 seconds, 30 seconds, 1 minute, 2 minutes)
Start recording with a single tap
View recording progress with a live timer and progress indicator
Stop recording manually before the selected duration if needed
Recording continues even when the app is minimized (captures only this app's screen)

🎬 Playback Screen

Browse all your recordings in a clean, organized list
View recording date, time, and duration for each entry
Play recordings directly within the app with a built-in video player
Delete unwanted recordings easily

📋 Requirements

Flutter 3.10.0 or higher
Dart 3.0.0 or higher
Android SDK 21+ or iOS 12+

📦 Dependencies
yamldependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5         # For state management
  path_provider: ^2.1.1    # For accessing device directories
  shared_preferences: ^2.2.2 # For storing recording metadata
  uuid: ^4.1.0             # For generating unique IDs
  permission_handler: ^11.0.1 # For handling permissions
  flutter_screen_recording: ^2.0.6 # For screen recording functionality
  video_player: ^2.7.2     # For video playback
  chewie: ^1.7.1           # For enhanced video player UI
  intl: ^0.18.1            # For date formatting

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
#   r e c o r d e r _ a p p  
 