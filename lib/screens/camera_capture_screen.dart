import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/responsive_helper.dart';
import '../utils/simple_location_helper.dart';
import '../services/jagmag_location_service.dart';
import '../widgets/jagmag_logo.dart';
import 'report_details_screen.dart';
import 'dart:developer' as developer;

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  int _selectedCameraIdx = 0;
  bool _isCameraInitialized = false;
  bool _isPermissionGranted = false;
  String _initializationError = "";
  bool _isDisposing = false;
  bool _isInitializing = false;
  bool _isRecording = false;
  bool _isTakingPicture = false;

  // Multiple images support
  List<XFile> _capturedImages = [];
  XFile? _recordedVideo;

  // Retry mechanism
  int _initRetryCount = 0;
  static const int _maxInitRetries = 3;
  static const Duration _initTimeout = Duration(seconds: 10);

  // Flash mode
  FlashMode _currentFlashMode = FlashMode.off;
  final List<FlashMode> _availableFlashModes = [
    FlashMode.off,
    FlashMode.auto,
    FlashMode.always,
  ];

  // Permission request flag
  bool _isRequestingPermission = false;

  @override
  void initState() {
    super.initState();
    developer.log(
      'CameraCaptureScreen: initState',
      name: 'CameraCaptureScreen',
    );
    WidgetsBinding.instance.addObserver(this);
    _requestPermissionAndInitializeCamera();
  }

  Future<void> _disposeController() async {
    if (_cameraController != null) {
      developer.log(
        'CameraCaptureScreen: Attempting to dispose controller.',
        name: 'CameraCaptureScreen',
      );
      try {
        if (_cameraController!.value.isStreamingImages) {
          await _cameraController!.stopImageStream();
        }
        await _cameraController!.dispose();
        developer.log(
          'CameraCaptureScreen: Controller disposed.',
          name: 'CameraCaptureScreen',
        );
      } catch (e, s) {
        developer.log(
          'CameraCaptureScreen: Error disposing controller: $e',
          name: 'CameraCaptureScreen',
          error: e,
          stackTrace: s,
        );
      } finally {
        if (mounted) {
          setState(() {
            _cameraController = null;
          });
        } else {
          _cameraController = null;
        }
      }
    }
  }

  Future<void> _requestPermissionAndInitializeCamera() async {
    if (_isRequestingPermission) {
      developer.log(
        'CameraCaptureScreen: Permission request already in progress.',
        name: 'CameraCaptureScreen',
      );
      return;
    }

    try {
      _isRequestingPermission = true;
      developer.log(
        'CameraCaptureScreen: Requesting camera permission...',
        name: 'CameraCaptureScreen',
      );
      if (!mounted) return;

      // Check if permission is already granted
      final cameraStatus = await Permission.camera.status;
      if (cameraStatus.isGranted) {
        developer.log(
          'CameraCaptureScreen: Camera permission already granted.',
          name: 'CameraCaptureScreen',
        );
        if (mounted) {
          setState(() {
            _isPermissionGranted = true;
            _initializationError = "";
          });
          await _initializeCamera();
        }
        return;
      }

      // Request permission if not already granted
      final requestStatus = await Permission.camera.request();

      if (!mounted) return;

      if (requestStatus.isGranted) {
        developer.log(
          'CameraCaptureScreen: Camera permission granted.',
          name: 'CameraCaptureScreen',
        );
        setState(() {
          _isPermissionGranted = true;
          _initializationError = "";
        });
        await _initializeCamera();
      } else {
        developer.log(
          'CameraCaptureScreen: Camera permission denied.',
          name: 'CameraCaptureScreen',
        );
        setState(() {
          _isPermissionGranted = false;
          _isCameraInitialized = false;
          _initializationError =
              'Camera permission denied. Please grant permission in settings.';
        });
        if (requestStatus.isPermanentlyDenied && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Camera permission is permanently denied. Please enable it in app settings.',
              ),
              action: SnackBarAction(
                label: 'Open Settings',
                onPressed: openAppSettings,
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingPermission = false;
        });
      } else {
        _isRequestingPermission = false;
      }
    }
  }

  Future<void> _initializeCamera() async {
    developer.log(
      'CameraCaptureScreen: Initializing camera...',
      name: 'CameraCaptureScreen',
    );
    if (!_isPermissionGranted || !mounted) {
      developer.log(
        'CameraCaptureScreen: Cannot initialize camera, permission not granted or not mounted.',
        name: 'CameraCaptureScreen',
      );
      if (mounted) {
        setState(() {
          _initializationError = "Camera permission not granted.";
          _isCameraInitialized = false;
        });
      }
      return;
    }
    if (_isDisposing) {
      developer.log(
        'CameraCaptureScreen: Attempted to initialize camera while disposing.',
        name: 'CameraCaptureScreen',
      );
      return;
    }

    if (_isInitializing) {
      developer.log(
        'CameraCaptureScreen: Camera initialization already in progress.',
        name: 'CameraCaptureScreen',
      );
      return;
    }

    setState(() {
      _isInitializing = true;
      _initializationError = "";
    });

    try {
      developer.log(
        'CameraCaptureScreen: Fetching available cameras...',
        name: 'CameraCaptureScreen',
      );
      _cameras = await availableCameras();
      if (!mounted) return;

      if (_cameras != null && _cameras!.isNotEmpty) {
        developer.log(
          'CameraCaptureScreen: ${_cameras!.length} cameras found.',
          name: 'CameraCaptureScreen',
        );
        int backCameraIdx = _cameras!.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
        );
        _selectedCameraIdx = (backCameraIdx != -1) ? backCameraIdx : 0;

        developer.log(
          'CameraCaptureScreen: Selected camera index: $_selectedCameraIdx',
          name: 'CameraCaptureScreen',
        );
        await _onNewCameraSelected(_cameras![_selectedCameraIdx]);
      } else {
        developer.log(
          'CameraCaptureScreen: No cameras available.',
          name: 'CameraCaptureScreen',
        );
        if (mounted) {
          setState(() {
            _isCameraInitialized = false;
            _initializationError = 'No cameras available on this device.';
            _isInitializing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No cameras found on this device.')),
          );
        }
      }
    } catch (e, s) {
      developer.log(
        'CameraCaptureScreen: Error during camera list fetching or initial selection: $e',
        name: 'CameraCaptureScreen',
        error: e,
        stackTrace: s,
      );
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
          _initializationError = 'Error finding cameras: ${e.toString()}';
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _onNewCameraSelected(CameraDescription cameraDescription) async {
    developer.log(
      'CameraCaptureScreen: Setting up new camera: ${cameraDescription.name}',
      name: 'CameraCaptureScreen',
    );
    if (!mounted || _isDisposing) return;

    if (_cameraController != null) {
      developer.log(
        'CameraCaptureScreen: Disposing previous camera controller in _onNewCameraSelected.',
        name: 'CameraCaptureScreen',
      );
      await _disposeController();
    }

    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: true, // Enable audio for video recording
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _cameraController!.addListener(() {
      if (mounted &&
          _cameraController != null &&
          _cameraController!.value.hasError) {
        developer.log(
          'CameraCaptureScreen: Camera Controller Error: ${_cameraController!.value.errorDescription}',
          name: 'CameraCaptureScreen',
        );
      }
    });

    try {
      developer.log(
        'CameraCaptureScreen: Initializing new camera controller...',
        name: 'CameraCaptureScreen',
      );

      bool initSuccess = false;
      await Future.any([
        _cameraController!.initialize().then((_) {
          initSuccess = true;
        }),
        Future.delayed(_initTimeout).then((_) {
          if (!initSuccess) {
            throw CameraException(
              'timeout',
              'Camera initialization timed out after ${_initTimeout.inSeconds} seconds',
            );
          }
        }),
      ]);

      developer.log(
        'CameraCaptureScreen: Camera controller initialized successfully. Aspect Ratio: ${_cameraController!.value.aspectRatio}',
        name: 'CameraCaptureScreen',
      );
      if (mounted && _cameraController != null) {
        await _cameraController!.setFlashMode(_currentFlashMode);
      }
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _initializationError = "";
          _isInitializing = false;
          _initRetryCount = 0;
        });
      }
    } on CameraException catch (e, s) {
      developer.log(
        'CameraCaptureScreen: CameraException during _onNewCameraSelected: ${e.code} - ${e.description}',
        name: 'CameraCaptureScreen',
        error: e,
        stackTrace: s,
      );
      _showCameraException(e);

      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
          _initializationError =
              'Failed to initialize camera: ${e.description}';
          _isInitializing = false;
        });

        if ((e.code == 'CameraAccessDenied' ||
                e.code == 'camera_error' ||
                e.description?.contains('busy') == true) &&
            _initRetryCount < _maxInitRetries) {
          _initRetryCount++;
          developer.log(
            'CameraCaptureScreen: Retrying camera initialization (attempt $_initRetryCount of $_maxInitRetries)',
            name: 'CameraCaptureScreen',
          );

          Future.delayed(Duration(milliseconds: 800 * _initRetryCount), () {
            if (mounted && !_isDisposing) {
              _onNewCameraSelected(cameraDescription);
            }
          });
        }
      }
    } catch (e, s) {
      developer.log(
        'CameraCaptureScreen: Generic error during _onNewCameraSelected: $e',
        name: 'CameraCaptureScreen',
        error: e,
        stackTrace: s,
      );
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
          _initializationError =
              'An unexpected error occurred: ${e.toString()}';
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    developer.log(
      'CameraCaptureScreen: AppLifecycleState changed to $state',
      name: 'CameraCaptureScreen',
    );

    final CameraController? currentCameraController = _cameraController;

    if (state == AppLifecycleState.inactive) {
      developer.log(
        'CameraCaptureScreen: App inactive.',
        name: 'CameraCaptureScreen',
      );
      _disposeController();
    } else if (state == AppLifecycleState.resumed) {
      developer.log(
        'CameraCaptureScreen: App resumed.',
        name: 'CameraCaptureScreen',
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted || _isDisposing) return;

        if (currentCameraController == null ||
            !currentCameraController.value.isInitialized) {
          developer.log(
            'CameraCaptureScreen: Controller not ready on resume, attempting re-init.',
            name: 'CameraCaptureScreen',
          );
          if (_isPermissionGranted) {
            _initializeCamera();
          } else {
            _requestPermissionAndInitializeCamera();
          }
        } else {
          developer.log(
            'CameraCaptureScreen: Controller was already initialized on resume.',
            name: 'CameraCaptureScreen',
          );
          currentCameraController.setFlashMode(_currentFlashMode).catchError((
            e,
          ) {
            _showCameraException(
              e is CameraException
                  ? e
                  : CameraException("FlashErrorOnResume", e.toString()),
            );
          });
        }
      });
    }
  }

  void _showCameraException(dynamic e) {
    String errorText;
    if (e is CameraException) {
      errorText = 'Camera Error: ${e.code}\n${e.description}';
    } else {
      errorText = 'An unknown camera error occurred: ${e.toString()}';
    }
    developer.log(
      errorText,
      name: 'CameraCaptureScreen._showCameraException',
      error: e,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is CameraException ? (e.description ?? e.code) : e.toString(),
          ),
        ),
      );
      setState(() {
        _initializationError = e is CameraException
            ? (e.description ?? e.code)
            : e.toString();
        _isCameraInitialized = false;
      });
    }
  }

  Future<void> _onTakePictureButtonPressed() async {
    developer.log(
      'CameraCaptureScreen: Take picture button pressed.',
      name: 'CameraCaptureScreen',
    );
    if (!_isCameraControllerAvailable() ||
        _cameraController!.value.isTakingPicture) {
      developer.log(
        'CameraCaptureScreen: Cannot take picture. Controller available: ${_isCameraControllerAvailable()}, IsTakingPicture: ${_cameraController?.value.isTakingPicture}',
        name: 'CameraCaptureScreen',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera not ready or currently busy.')),
        );
      }
      return;
    }

    setState(() {
      _isTakingPicture = true;
    });

    try {
      developer.log(
        'CameraCaptureScreen: Taking picture...',
        name: 'CameraCaptureScreen',
      );
      final XFile imageFile = await _cameraController!.takePicture();
      developer.log(
        'CameraCaptureScreen: Picture taken: ${imageFile.path}',
        name: 'CameraCaptureScreen',
      );

      setState(() {
        _capturedImages.add(imageFile);
        _isTakingPicture = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image captured! Total: ${_capturedImages.length}'),
          ),
        );
      }
    } on CameraException catch (e) {
      developer.log(
        'CameraCaptureScreen: CameraException during takePicture: ${e.code}',
        name: 'CameraCaptureScreen',
        error: e,
      );
      _showCameraException(e);
      setState(() {
        _isTakingPicture = false;
      });
    } catch (e) {
      developer.log(
        'CameraCaptureScreen: Generic error during takePicture: $e',
        name: 'CameraCaptureScreen',
        error: e,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking picture: ${e.toString()}')),
        );
      }
      setState(() {
        _isTakingPicture = false;
      });
    }
  }

  Future<void> _onVideoRecordingButtonPressed() async {
    if (!_isCameraControllerAvailable()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Camera not ready.')));
      return;
    }

    if (_isRecording) {
      // Stop recording
      try {
        final XFile videoFile = await _cameraController!.stopVideoRecording();
        setState(() {
          _isRecording = false;
          _recordedVideo = videoFile;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video recording stopped!')),
          );
        }
      } catch (e) {
        developer.log(
          'Error stopping video recording: $e',
          name: 'CameraCaptureScreen',
        );
        setState(() {
          _isRecording = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error stopping video: ${e.toString()}')),
        );
      }
    } else {
      // Start recording
      try {
        await _cameraController!.startVideoRecording();
        setState(() {
          _isRecording = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video recording started! Tap again to stop.'),
            ),
          );
        }

        // Auto-stop after 10 seconds
        Future.delayed(const Duration(seconds: 10), () {
          if (_isRecording && mounted) {
            _onVideoRecordingButtonPressed();
          }
        });
      } catch (e) {
        developer.log(
          'Error starting video recording: $e',
          name: 'CameraCaptureScreen',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting video: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _onFlashModeButtonPressed() async {
    if (!_isCameraControllerAvailable()) return;

    int nextModeIndex =
        (_availableFlashModes.indexOf(_currentFlashMode) + 1) %
        _availableFlashModes.length;
    FlashMode nextFlashMode = _availableFlashModes[nextModeIndex];

    try {
      await _cameraController!.setFlashMode(nextFlashMode);
      if (mounted) {
        setState(() {
          _currentFlashMode = nextFlashMode;
        });
      }
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  Future<void> _onSwitchCameraButtonPressed() async {
    if (_cameras != null &&
        _cameras!.length > 1 &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _selectedCameraIdx = (_selectedCameraIdx + 1) % _cameras!.length;
      developer.log(
        "Switching to camera index: $_selectedCameraIdx",
        name: "CameraCaptureScreen",
      );
      await _onNewCameraSelected(_cameras![_selectedCameraIdx]);
    }
  }

  Future<void> _onProceedButtonPressed() async {
    if (_capturedImages.isEmpty && _recordedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please capture at least one image or video before proceeding.',
          ),
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Getting location...'),
            ],
          ),
        );
      },
    );

    try {
      // Check if we have location permission, request if needed
      bool hasPermission =
          await SimpleLocationHelper.requestLocationPermissionOnce(context);

      if (!hasPermission) {
        Navigator.of(context).pop(); // Close loading dialog
        return;
      }

      // Get location
      final locationResult = await JagmagLocationService.getCurrentLocation();

      Navigator.of(context).pop(); // Close loading dialog

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailsScreen(
              capturedImages: _capturedImages,
              recordedVideo: _recordedVideo,
              locationData: locationResult,
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getFlashIcon(FlashMode mode) {
    switch (mode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.torch:
        return Icons.highlight;
    }
  }

  @override
  void dispose() {
    developer.log(
      'CameraCaptureScreen: dispose() called.',
      name: 'CameraCaptureScreen',
    );
    _isDisposing = true;
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();

    _disposeController().catchError((error) {
      developer.log(
        'Error disposing camera controller: $error',
        name: 'CameraCaptureScreen',
      );
    });

    developer.log(
      'CameraCaptureScreen: dispose() finished.',
      name: 'CameraCaptureScreen',
    );
  }

  bool _isCameraControllerAvailable() {
    return _cameraController != null &&
        !_isDisposing &&
        mounted &&
        _cameraController!.value.isInitialized;
  }

  @override
  Widget build(BuildContext context) {
    developer.log(
      'CameraCaptureScreen: Build method called. IsCameraInitialized: $_isCameraInitialized, IsPermissionGranted: $_isPermissionGranted, InitError: $_initializationError, Controller: ${_cameraController != null}, Controller Initialized: ${_cameraController?.value.isInitialized}',
      name: 'CameraCaptureScreen',
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            JagmagLogo(size: 30),
            const SizedBox(width: 10),
            Text(
              'Capture Issue',
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 18),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_capturedImages.isNotEmpty || _recordedVideo != null)
            TextButton(
              onPressed: _onProceedButtonPressed,
              child: Text(
                'Proceed (${_capturedImages.length + (_recordedVideo != null ? 1 : 0)})',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Builder(
        builder: (BuildContext scaffoldContext) {
          if (!_isPermissionGranted) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.no_photography,
                      size: 80,
                      color: Colors.white54,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _initializationError.isNotEmpty
                          ? _initializationError
                          : 'Camera permission is required to report issues.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _requestPermissionAndInitializeCamera,
                      child: const Text('Grant Permission'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!_isCameraInitialized ||
              _cameraController == null ||
              !_cameraController!.value.isInitialized) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 20),
                    Text(
                      _initializationError.isNotEmpty
                          ? 'Error: $_initializationError'
                          : 'Initializing Camera...',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    if (_initializationError.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _requestPermissionAndInitializeCamera,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                    margin: const EdgeInsets.all(0),
                    color: Colors.black,
                    child: OverflowBox(
                      maxWidth: double.infinity,
                      maxHeight: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _cameraController!.value.previewSize!.height,
                          height: _cameraController!.value.previewSize!.width,
                          child: CameraPreview(_cameraController!),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _buildControls(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      color: Colors.black.withAlpha(180),
      child: Column(
        children: [
          // Captured media preview
          if (_capturedImages.isNotEmpty || _recordedVideo != null)
            Container(
              height: 80,
              margin: const EdgeInsets.only(bottom: 20),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ..._capturedImages.map(
                    (image) => Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(image.path),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _capturedImages.remove(image);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_recordedVideo != null)
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.videocam,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _recordedVideo = null;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

          // Camera controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  _getFlashIcon(_currentFlashMode),
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: _onFlashModeButtonPressed,
                tooltip:
                    'Flash Mode: ${_currentFlashMode.toString().split('.').last}',
              ),

              // Main capture button
              GestureDetector(
                onTap: _isTakingPicture ? null : _onTakePictureButtonPressed,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isTakingPicture ? Colors.grey : Colors.white,
                    border: Border.all(color: Colors.grey.shade400, width: 3),
                  ),
                  child: _isTakingPicture
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                          size: 35,
                        ),
                ),
              ),

              // Video recording button
              GestureDetector(
                onTap: _onVideoRecordingButtonPressed,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording
                        ? Colors.red
                        : Colors.white.withOpacity(0.3),
                    border: Border.all(
                      color: _isRecording ? Colors.red : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.videocam,
                    color: _isRecording ? Colors.white : Colors.white,
                    size: 24,
                  ),
                ),
              ),

              // Camera switch button
              (_cameras != null && _cameras!.length > 1)
                  ? IconButton(
                      icon: const Icon(
                        Icons.switch_camera,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: _onSwitchCameraButtonPressed,
                      tooltip: 'Switch Camera',
                    )
                  : const SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }
}
