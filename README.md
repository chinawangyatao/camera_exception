# Camera Exception Demo

This Flutter project demonstrates camera functionality and potential issues that may occur during camera operations, particularly on Android devices.

## Project Structure

The project contains two main camera implementations:

1. **Original Camera Demo** (`camera_preview.dart`) - A simplified camera implementation
2. **Android Camera Demo** (`camera_android_preview.dart`) - An Android-focused camera implementation with enhanced error handling

## Features

### Camera Selection Screen
- Choose between different camera implementations
- Compare behavior and error handling approaches

### Camera Functionality
- Camera initialization and preview
- Photo capture with error handling
- Camera switching (front/back)
- Real-time error display and user feedback

## Dependencies

```yaml
dependencies:
  camera: ^0.11.2
  camera_android: ^0.10.10+5
```

## Android Configuration

The project requires specific Android SDK and NDK versions:

- **Compile SDK**: 36
- **NDK Version**: 27.0.12077973
- **Min SDK**: 21

### Permissions

Add the following permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

## iOS Configuration

Add camera usage descriptions to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for video recording</string>
```

## Running the Project

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run on Android device**:
   ```bash
   flutter run -d <device_id>
   ```

3. **Run on iOS device**:
   ```bash
   flutter run -d <device_id>
   ```

## Common Issues and Demonstrations

### Android-Specific Issues

1. **Camera Initialization Failures**
   - Hardware access conflicts
   - Permission denied errors
   - Unsupported resolution configurations

2. **Photo Capture Errors**
   - Insufficient storage space
   - Camera hardware malfunctions
   - Concurrent camera access issues

3. **Camera Switching Problems**
   - Hardware limitations on some devices
   - Resource allocation conflicts

### Error Handling Features

- **Real-time error display**: Shows detailed error messages to users
- **Graceful degradation**: Continues functioning even when some features fail
- **Recovery mechanisms**: Allows users to reinitialize camera when errors occur
- **User feedback**: Provides clear instructions and status updates

## Code Structure

### `main.dart`
- Application entry point
- Camera selection screen implementation
- Navigation between different camera demos

### `camera_preview.dart`
- Original simplified camera implementation
- Basic error handling
- Minimal UI for demonstration purposes

### `camera_android_preview.dart`
- Android-focused camera implementation
- Enhanced error handling and user feedback
- Detailed logging for debugging
- Android-specific configurations and optimizations

## Development Notes

### English Comments
All code comments are written in English as requested, following best practices for international development.

### Error Demonstration
Both implementations are designed to potentially trigger various camera-related errors for educational and debugging purposes.

### Platform Considerations
While both implementations use the standard `camera` plugin, the Android version includes specific configurations and error handling approaches optimized for Android devices.

## Troubleshooting

### Build Issues
1. Ensure Android SDK 36 is installed
2. Update NDK to version 27.0.12077973
3. Check that all permissions are properly configured

### Runtime Issues
1. Verify camera permissions are granted
2. Check device camera hardware availability
3. Ensure sufficient storage space for photo capture

### Testing
1. Test on multiple Android devices with different hardware configurations
2. Test camera switching functionality
3. Test error scenarios (deny permissions, insufficient storage, etc.)

## Purpose

This demo serves as:
- A learning tool for understanding camera plugin usage
- A testing ground for camera-related error scenarios
- A comparison between different implementation approaches
- A reference for proper error handling in camera applications
