import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/responsive_helper.dart';
import '../services/jagmag_location_service.dart';
import '../services/jagmag_ai_service.dart';
import 'report_details_screen.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Request camera permission
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
      });

      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(
          cameras[0],
          ResolutionPreset.high,
          enableAudio: false,
        );

        try {
          await _controller!.initialize();
          if (mounted) {
            setState(() {
              _isInitialized = true;
            });
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error initializing camera: $e')),
            );
          }
        }
      }
    } else {
      setState(() {
        _hasPermission = false;
      });
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile image = await _controller!.takePicture();
      
      // Get location
      final locationResult = await JagmagLocationService.getCurrentLocation();
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailsScreen(
              imageFile: File(image.path),
              locationData: locationResult,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Capture Issue',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_hasPermission) {
      return _buildPermissionDenied();
    }

    if (!_isInitialized) {
      return _buildLoading();
    }

    return _buildCameraView();
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt,
            size: ResponsiveHelper.getIconSize(context, 80),
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Camera Permission Required',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 20),
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Please grant camera permission to capture issue photos',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 16),
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              await Permission.camera.request();
              _initializeCamera();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Grant Permission',
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.blue[600],
          ),
          const SizedBox(height: 20),
          Text(
            'Initializing Camera...',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 16),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        // Camera preview
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CameraPreview(_controller!),
        ),
        
        // Overlay with instructions
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Point camera at the issue and tap the capture button',
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 14),
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        
        // Capture button
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _isCapturing ? null : _captureImage,
              child: Container(
                width: ResponsiveHelper.isMobile(context) ? 80 : 100,
                height: ResponsiveHelper.isMobile(context) ? 80 : 100,
                decoration: BoxDecoration(
                  color: _isCapturing ? Colors.grey[600] : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blue[600]!,
                    width: 4,
                  ),
                ),
                child: _isCapturing
                    ? CircularProgressIndicator(
                        color: Colors.blue[600],
                      )
                    : Icon(
                        Icons.camera_alt,
                        size: ResponsiveHelper.getIconSize(context, 40),
                        color: Colors.blue[600],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
