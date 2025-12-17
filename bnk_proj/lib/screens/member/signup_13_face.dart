import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:test_main/models/cust_info.dart';
import 'package:test_main/screens/member/signup_14.dart';

class FaceCapturePage extends StatefulWidget {
  const FaceCapturePage({super.key, required this.custInfo, });
  final CustInfo custInfo;

  @override
  State<FaceCapturePage> createState() => _FaceCapturePageState();
}

class _FaceCapturePageState extends State<FaceCapturePage> {
  CameraController? _controller;
  bool _isFaceDetected = false;
  late FaceDetector _faceDetector;


  @override
  void initState() {
    super.initState();
    _initCamera();

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableClassification: true,
      ),
    );
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller!.initialize();
    if (mounted) setState(() {});
  }






  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _takePicture() async {
    final image = await _controller!.takePicture();

    final inputImage = InputImage.fromFilePath(image.path);
    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("얼굴이 인식되지 않았어요. 다시 촬영해주세요.")),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FaceCaptureCompletePage(
          custInfo: widget.custInfo,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_controller!),

          /// 🔲 타원 가이드
          const _OvalOverlay(),

          /// 안내 문구
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "화면 가운데로 얼굴 정면을 맞춰주세요",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          /// 촬영 버튼
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  debugPrint("📸 버튼 눌림 / isFaceDetected=$_isFaceDetected");
                  _takePicture();
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isFaceDetected
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                      width: 4,
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// 닫기
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _OvalOverlay extends StatelessWidget {
  const _OvalOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          height: MediaQuery.of(context).size.width * 0.95,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 3),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}
