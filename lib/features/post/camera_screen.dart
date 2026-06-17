// 撮影画面。表示時にカメラを自動起動し、動画を撮影する。
// イン/アウトカメラ切替・タイマー設定も担当。撮影後は送信画面へ。

import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation.dart';
import 'post_provider.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  List<CameraDescription> _cameras = const [];
  CameraController? _controller;
  int _cameraIndex = 0;
  bool _isRecording = false;
  bool _initializing = true;
  String? _error;

  // 撮影開始までのカウントダウン秒数（タイマー設定）。0なら即時。
  int _timerSeconds = 0;
  int _countdown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _setupCameras();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _setupCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _error = '利用可能なカメラが見つかりません';
          _initializing = false;
        });
        return;
      }
      await _initController(_cameraIndex);
    } catch (e) {
      setState(() {
        _error = 'カメラの起動に失敗しました: $e';
        _initializing = false;
      });
    }
  }

  Future<void> _initController(int index) async {
    final previous = _controller;
    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.medium,
      enableAudio: true,
    );
    try {
      await controller.initialize();
      await previous?.dispose();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _cameraIndex = index;
        _initializing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'カメラの初期化に失敗しました: $e';
        _initializing = false;
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isRecording) return;
    setState(() => _initializing = true);
    await _initController((_cameraIndex + 1) % _cameras.length);
  }

  void _onShutterPressed() {
    if (_isRecording) {
      _stopRecording();
      return;
    }
    if (_timerSeconds > 0) {
      _startCountdown();
    } else {
      _startRecording();
    }
  }

  void _startCountdown() {
    setState(() => _countdown = _timerSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        setState(() => _countdown = 0);
        _startRecording();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  Future<void> _startRecording() async {
    final controller = _controller;
    if (controller == null || _isRecording) return;
    try {
      await controller.startVideoRecording();
      setState(() => _isRecording = true);
    } catch (e) {
      setState(() => _error = '録画開始に失敗しました: $e');
    }
  }

  Future<void> _stopRecording() async {
    final controller = _controller;
    if (controller == null || !_isRecording) return;
    try {
      final file = await controller.stopVideoRecording();
      setState(() => _isRecording = false);
      ref.read(recordedVideoProvider.notifier).set(file);
      if (mounted) context.push('/send');
    } catch (e) {
      setState(() {
        _isRecording = false;
        _error = '録画停止に失敗しました: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('撮影'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.backOrHome(),
        ),
      ),
      body: SafeArea(
        child: _error != null
            ? _ErrorView(message: _error!)
            : _initializing || _controller == null
                ? const Center(child: CircularProgressIndicator())
                : _buildCameraView(),
      ),
    );
  }

  Widget _buildCameraView() {
    final controller = _controller!;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: CameraPreview(controller),
                ),
                if (_countdown > 0)
                  Text(
                    '$_countdown',
                    style: const TextStyle(
                      fontSize: 96,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
        _buildControls(),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _TimerButton(
            seconds: _timerSeconds,
            enabled: !_isRecording && _countdown == 0,
            onTap: _cycleTimer,
          ),
          GestureDetector(
            onTap: _countdown > 0 ? null : _onShutterPressed,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isRecording ? Colors.red : Colors.white,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Icon(
                _isRecording ? Icons.stop : Icons.videocam,
                color: _isRecording ? Colors.white : Colors.black,
              ),
            ),
          ),
          IconButton(
            iconSize: 32,
            color: Colors.white,
            icon: const Icon(Icons.cameraswitch),
            onPressed:
                _cameras.length < 2 || _isRecording ? null : _switchCamera,
          ),
        ],
      ),
    );
  }

  // タイマー設定を 0→3→5→10→0 と切り替える。
  void _cycleTimer() {
    const options = [0, 3, 5, 10];
    final next = options[(options.indexOf(_timerSeconds) + 1) % options.length];
    setState(() => _timerSeconds = next);
  }
}

class _TimerButton extends StatelessWidget {
  const _TimerButton({
    required this.seconds,
    required this.enabled,
    required this.onTap,
  });

  final int seconds;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: enabled ? onTap : null,
      icon: const Icon(Icons.timer, color: Colors.white),
      label: Text(
        seconds == 0 ? 'OFF' : '${seconds}s',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
