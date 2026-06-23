// 撮影画面。表示時にカメラを自動起動し、動画を撮影する。
// イン/アウトカメラ切替・タイマー設定も担当。撮影後は送信画面へ。

import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
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

  // 録画は2秒で自動停止する（Setlog風の短尺ログ）。
  static const _recordDuration = Duration(seconds: 2);
  Timer? _recordTimer;

  @override
  void initState() {
    super.initState();
    _setupCameras();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recordTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _setupCameras() async {
    try {
      final all = await availableCameras();
      if (all.isEmpty) {
        setState(() {
          _error = '利用可能なカメラが見つかりません';
          _initializing = false;
        });
        return;
      }
      // iPhoneは背面が広角/超広角/望遠など複数返るため、
      // 背面・前面それぞれ1台ずつに絞って切替対象を [背面, 前面] に固定する。
      final back = all.where((c) => c.lensDirection == CameraLensDirection.back);
      final front =
          all.where((c) => c.lensDirection == CameraLensDirection.front);
      _cameras = [
        if (back.isNotEmpty) back.first,
        if (front.isNotEmpty) front.first,
      ];
      if (_cameras.isEmpty) _cameras = all;

      await _initController(0);
    } catch (e) {
      setState(() {
        _error = 'カメラの起動に失敗しました: $e';
        _initializing = false;
      });
    }
  }

  Future<void> _initController(int index) async {
    // iOSは複数のキャプチャセッションを同時に開けないため、
    // 新しいカメラを起動する前に必ず旧コントローラを破棄する（切替で死ぬのを防ぐ）。
    await _controller?.dispose();
    _controller = null;

    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.medium,
      enableAudio: true,
    );
    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _cameraIndex = index;
        _initializing = false;
      });
    } catch (e, st) {
      debugPrint('[camera] 初期化失敗 index=$index '
          'dir=${_cameras[index].lensDirection}: $e');
      debugPrint('[camera] $st');
      if (!mounted) return;
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
      // 2秒経過で自動停止する。
      _recordTimer = Timer(_recordDuration, _stopRecording);
    } catch (e) {
      setState(() => _error = '録画開始に失敗しました: $e');
    }
  }

  Future<void> _stopRecording() async {
    _recordTimer?.cancel();
    final controller = _controller;
    if (controller == null || !_isRecording) return;
    try {
      final file = await controller.stopVideoRecording();
      setState(() => _isRecording = false);
      ref
          .read(recordedVideoProvider.notifier)
          .set(RecordedVideo(file: file, needsFlip: _needsFlip));
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
      body: SafeArea(
        child: _error != null
            ? _ErrorView(message: _error!)
            : _initializing || _controller == null
                ? const Center(child: CircularProgressIndicator())
                : _buildCameraView(),
      ),
    );
  }

  // 縦長フレームに横向きで撮影する（プレビューは画面いっぱいにcover表示）。
  Widget _buildCameraView() {
    final controller = _controller!;

    return Stack(
      children: [
        Positioned.fill(child: _buildPreview(controller)),
        // 撮影中・待機中は中央に横向きで現在時刻を表示する。
        // カウントダウン中は数字と被るため時刻は隠す。
        if (_countdown == 0)
          Center(
            child: RotatedBox(
              quarterTurns: 1,
              child: Text(
                _currentTimeLabel,
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 12, color: Colors.black54)],
                ),
              ),
            ),
          )
        else
          Center(
            child: Text(
              '$_countdown',
              style: const TextStyle(
                fontSize: 96,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        Positioned(
          top: 8,
          right: 8,
          child: _CircleButton(
            icon: Icons.close,
            onTap: () => context.backOrHome(),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildControls(),
        ),
      ],
    );
  }

  // カメラプレビューを画面いっぱいにcover表示する。
  // Web のカメラは横長で返るため、縦長画面に合わせて切り抜いて表示する。
  // スマホは従来通りスケール係数で歪みなくcover表示する。
  Widget _buildPreview(CameraController controller) {
    if (kIsWeb) {
      // 横長のWebカメラ映像を、縦長枠に回転させずcoverで切り抜いて表示する（鏡のまま）。
      final preview = controller.value.previewSize;
      return ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: preview?.width ?? 16,
            height: preview?.height ?? 9,
            child: CameraPreview(controller),
          ),
        ),
      );
    }
    final mediaSize = MediaQuery.of(context).size;
    final scale = 1 / (controller.value.aspectRatio * mediaSize.aspectRatio);
    return ClipRect(
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.center,
        child: Center(child: CameraPreview(controller)),
      ),
    );
  }

  // Android前面カメラはファイル自体が上下逆に記録されるため、再生側で補正させる。
  bool get _needsFlip {
    if (kIsWeb || _cameras.isEmpty) return false;
    return defaultTargetPlatform == TargetPlatform.android &&
        _cameras[_cameraIndex].lensDirection == CameraLensDirection.front;
  }

  String get _currentTimeLabel {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildControls() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black54],
        ),
      ),
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

// 半透明の丸型アイコンボタン（閉じるボタン用）。
class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Icon(icon, size: 22, color: Colors.black87),
      ),
    );
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
