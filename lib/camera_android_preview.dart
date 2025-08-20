import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Camera preview demo using camera plugin with Android-specific configuration
/// This demonstrates potential issues that may occur during camera operations
class CameraAndroidPreview extends StatefulWidget {
  const CameraAndroidPreview({super.key});

  @override
  State<CameraAndroidPreview> createState() => _CameraAndroidPreviewState();
}

class _CameraAndroidPreviewState extends State<CameraAndroidPreview> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isTakingPicture = false;
  String? _lastImagePath; // Store the path of the last taken photo

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  /// Initialize camera using standard camera plugin
  /// This method may encounter various Android-specific issues
  Future<void> _initializeCamera() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get available cameras using standard camera plugin
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras found on this device.';
          _isLoading = false;
        });
        return;
      }

      // Initialize camera controller with standard camera plugin
      // Using medium resolution to potentially trigger Android-specific issues
      _cameraController = CameraController(
        _cameras[0], // Use first available camera (usually back camera)
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // Initialize the controller - this may fail on some Android devices
      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Camera initialization failed: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  /// Take picture using standard camera plugin - may trigger Android-specific errors
  /// This method demonstrates potential issues that can occur during photo capture
  Future<void> _takePicture() async {
    if (!_isCameraInitialized ||
        _cameraController == null ||
        _isTakingPicture) {
      return;
    }

    setState(() {
      _isTakingPicture = true;
    });

    try {
      // Check if controller is initialized
      if (!_cameraController!.value.isInitialized) {
        throw CameraException(
          'NotInitialized',
          'Camera controller not initialized',
        );
      }

      // Attempt to take picture - this may cause various Android-specific errors
      // Common issues: insufficient storage, camera hardware problems, etc.
      final XFile image = await _cameraController!.takePicture();

      print("Photo taken successfully on Android: ${image.path}");

      // Store the image path to display in UI
      setState(() {
        _lastImagePath = image.path;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo saved on Android: ${image.path}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Android camera photo error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Android camera photo failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPicture = false;
        });
      }
    }
  }

  /// Switch to front/back camera if available
  /// This operation may fail on some Android devices due to hardware limitations
  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    try {
      setState(() {
        _isCameraInitialized = false;
        _isLoading = true;
      });

      // Find the next camera (front/back switch)
      final currentCamera = _cameraController?.description;
      CameraDescription? nextCamera;

      for (final camera in _cameras) {
        if (camera != currentCamera) {
          nextCamera = camera;
          break;
        }
      }

      if (nextCamera != null) {
        await _cameraController?.dispose();

        _cameraController = CameraController(
          nextCamera,
          ResolutionPreset.medium,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        await _cameraController!.initialize();

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Android camera switch failed: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Android Exception Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Switch camera button
          if (_cameras.length > 1 && _isCameraInitialized)
            IconButton(
              onPressed: _switchCamera,
              icon: const Icon(Icons.flip_camera_android),
              tooltip: 'Switch Android Camera',
            ),
        ],
      ),
      body: Column(
        children: [
          // Camera preview area
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: _buildCameraWidget(),
            ),
          ),
          // Control buttons area
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Take picture button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: (_isCameraInitialized && !_isTakingPicture)
                        ? _takePicture
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: _isTakingPicture
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('Taking photo on Android...'),
                            ],
                          )
                        : const Text(
                            'Take Photo (Android Camera)',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                // Reinitialize camera button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _initializeCamera,
                    child: const Text('Reinitialize Android Camera'),
                  ),
                ),
                const SizedBox(height: 10),
                // Display last taken photo
                if (_lastImagePath != null) ...[
                  const Text(
                    'Last Photo Taken:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_lastImagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error, color: Colors.red),
                                Text('Failed to load image'),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Path: $_lastImagePath',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                ],
                // Info text
                const Text(
                  'This demo uses standard camera plugin with Android-specific configurations',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build camera preview widget
  Widget _buildCameraWidget() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
           const Text(
              'Initializing Android camera...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    if (_isCameraInitialized && _cameraController != null) {
      return CameraPreview(_cameraController!);
    }

    return const Center(
      child: Text(
        'Android camera is not ready',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}