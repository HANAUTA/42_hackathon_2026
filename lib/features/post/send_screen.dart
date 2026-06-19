// 送信画面。撮影動画をプレビューし、送信先グループを選んで投稿する。
// 1時間制限で送信済みのグループはグレーアウトして選択不可にする。

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../core/navigation.dart';
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
  // 自分のログへの投稿（時間制限なし）。初期状態でオン。
  bool _postToSelf = true;
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
    context.backOrHome();
  }

  Future<void> _send() async {
    final video = ref.read(recordedVideoProvider);
    if (video == null || _sending) return;
    if (!_postToSelf && _selectedGroupIds.isEmpty) return;

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
                onPressed: () => context.backOrHome(),
                child: const Text('撮影画面へ戻る'),
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
              child: Text('送信先', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          _buildSelfTile(),
          const Divider(height: 1),
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
      width: double.infinity,
      child: controller != null && controller.value.isInitialized
          // 撮影時(縦長フレーム)の見た目を90度回転した横長(16:9)で表示する。
          // 動画全体ではなく、撮影時と同じ枠に切り抜く（ホーム・グループ詳細と統一）。
          ? AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRect(
                child: FittedBox(
                  fit: BoxFit.cover,
                  // Webは撮影プレビュー(鏡)と向きを揃えるため左右反転する。
                  child: Transform.scale(
                    scaleX: kIsWeb ? -1 : 1,
                    scaleY: 1,
                    // Webカメラはスマホと逆方向に倒れて録画されるため回転方向を変える。
                    child: RotatedBox(
                      quarterTurns: kIsWeb ? 1 : 3,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            ),
    );
  }

  // 「自分のログへあげる」選択肢。常に表示し、時間制限はかからない。
  Widget _buildSelfTile() {
    return CheckboxListTile(
      value: _postToSelf,
      onChanged: _sending
          ? null
          : (checked) => setState(() => _postToSelf = checked ?? false),
      secondary: const Icon(Icons.person_outline),
      title: const Text('自分のログへあげる'),
      subtitle: const Text('時間制限なし'),
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
    final canSend = (_postToSelf || _selectedGroupIds.isNotEmpty) && !_sending;
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
