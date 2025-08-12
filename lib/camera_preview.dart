import 'package:camera/camera.dart' as camera;
import 'package:flutter/material.dart';

class CameraPreview extends StatefulWidget {
  const CameraPreview({super.key});

  @override
  State<CameraPreview> createState() => _CameraPreviewState();
}

class _CameraPreviewState extends State<CameraPreview> {
  camera.CameraController? _cameraController;
  List<camera.CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isTakingPicture = false;

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

  Future<void> _initializeCamera() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // 获取可用相机列表
      _cameras = await camera.availableCameras();

      if (_cameras.isEmpty) {
        setState(() {
          _errorMessage = 'Camera not found.';
          _isLoading = false;
        });
        return;
      }

      // 初始化相机控制器
      _cameraController = camera.CameraController(
        _cameras[0],
        camera.ResolutionPreset.medium,
        enableAudio: false,
      );

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

  /// This method will trigger an error - for demonstration purposes
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
      // 检查控制器是否已初始化
      if (!_cameraController!.value.isInitialized) {
        throw camera.CameraException('NotInit', 'Controller not initialized');
      }

      // 尝试拍照 - 这里可能会出现各种错误
      final camera.XFile image = await _cameraController!.takePicture();

      print("Photo taken successfully: ${image.path}");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('The photo has been saved.: ${image.path}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Photo error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo failed: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Exception Demonstration'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // 相机预览区域
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: _buildCameraWidget(),
            ),
          ),
          // 控制按钮区域
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 拍照按钮
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed:
                        (_isCameraInitialized && !_isTakingPicture)
                            ? _takePicture
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child:
                        _isTakingPicture
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
                                Text('In the process of taking a photo...'),
                              ],
                            )
                            : const Text(
                              'Click to take a photo',
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                ),
                const SizedBox(height: 10),
                // 重新初始化按钮
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _initializeCamera,
                    child: const Text('Reinitialize the camera'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraWidget() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Initializing camera...',
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
            const Icon(Icons.error_outline, color: Colors.white, size: 64),
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
      return camera.CameraPreview(_cameraController!);
    }

    return const Center(
      child: Text(
        'Camera is not ready.',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
