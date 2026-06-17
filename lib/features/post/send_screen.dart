// 送信画面。撮影動画をプレビューし、送信先グループを選んで投稿する。
// 1時間制限で送信済みのグループはグレーアウトして選択不可にする。

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../models/group.dart';
import 'post_provider.dart';
import 'video_preview_factory.dart';

class SendScreen extends ConsumerStatefulWidget {
  const SendScreen({super.key});

  @override
  ConsumerState<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends ConsumerState<SendScreen> {
  VideoPlayerController? _videoController;
  final Set<String> _selectedGroupIds = {};
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final video = ref.read(recordedVideoProvider);
    if (video != null) _initPreview(video);
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initPreview(XFile video) async {
    final controller = createPreviewController(video.path);
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _videoController = controller);
    } catch (_) {
      await controller.dispose();
    }
  }

  // 撮影画面へ戻る。動画は破棄する。
  void _cancel() {
    ref.read(recordedVideoProvider.notifier).clear();
    context.go('/camera');
  }

  Future<void> _send() async {
    final video = ref.read(recordedVideoProvider);
    if (video == null || _selectedGroupIds.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      await ref.read(postControllerProvider).send(
            video: video,
            groupIds: _selectedGroupIds.toList(),
          );
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('送信に失敗しました: $e')),
        );
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final video = ref.watch(recordedVideoProvider);
    if (video == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('送信')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('動画がありません'),
              TextButton(
                onPressed: () => context.go('/camera'),
                child: const Text('撮影画面へ'),
              ),
            ],
          ),
        ),
      );
    }

    final targets = ref.watch(sendTargetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('送信'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _sending ? null : _cancel,
        ),
      ),
      body: Column(
        children: [
          _buildPreview(),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('送信先グループ', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: targets.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('グループの取得に失敗しました: $e')),
              data: (data) => _buildGroupList(data),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildPreview() {
    final controller = _videoController;
    return Container(
      color: Colors.black,
      height: 220,
      width: double.infinity,
      child: controller != null && controller.value.isInitialized
          ? Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildGroupList(SendTargets data) {
    if (data.groups.isEmpty) {
      return const Center(child: Text('参加中のグループがありません'));
    }
    return ListView(
      children: [
        for (final group in data.groups)
          _buildGroupTile(group, data.postedGroupIds.contains(group.id)),
      ],
    );
  }

  Widget _buildGroupTile(Group group, bool alreadyPosted) {
    final selected = _selectedGroupIds.contains(group.id);
    return CheckboxListTile(
      value: selected,
      // 同時間帯に投稿済みのグループは選択不可（1時間に1回制限）。
      onChanged: alreadyPosted || _sending
          ? null
          : (checked) {
              setState(() {
                if (checked == true) {
                  _selectedGroupIds.add(group.id);
                } else {
                  _selectedGroupIds.remove(group.id);
                }
              });
            },
      title: Text(
        group.name,
        style: TextStyle(color: alreadyPosted ? Colors.grey : null),
      ),
      subtitle: alreadyPosted ? const Text('この時間帯は投稿済み') : null,
    );
  }

  Widget _buildBottomBar() {
    final canSend = _selectedGroupIds.isNotEmpty && !_sending;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FilledButton.icon(
          onPressed: canSend ? _send : null,
          icon: _sending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send),
          label: Text(_sending ? '送信中...' : '送信'),
        ),
      ),
    );
  }
}
