// グループ詳細画面。時間・日付移動による投稿フィルタリングUI。
// 時間移動（左右タップ・1時間）／日付移動（左右スワイプ・1日）／
// メンバー一覧・招待コード表示・グループ退出を担当する。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../models/app_user.dart';
import '../../models/group.dart';
import 'group_provider.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  // 表示対象のグループID（ルートの /group/:id から受け取る）。
  final String groupId;

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  late DateTime _date;
  late int _hour;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _date = DateTime(now.year, now.month, now.day);
    _hour = now.hour;
  }

  void _changeHour(int delta) {
    final next = _hour + delta;
    if (next < 0 || next > 23) return;
    setState(() => _hour = next);
  }

  void _changeDate(int deltaDays) {
    setState(() => _date = _date.add(Duration(days: deltaDays)));
  }

  String get _dateLabel =>
      '${_date.year}/${_date.month.toString().padLeft(2, '0')}/${_date.day.toString().padLeft(2, '0')}';

  String get _hourLabel =>
      '${_hour.toString().padLeft(2, '0')}:00〜${_hour.toString().padLeft(2, '0')}:59';

  @override
  Widget build(BuildContext context) {
    final groupAsync = ref.watch(groupProvider(widget.groupId));
    final args = GroupPostsArgs(
      groupId: widget.groupId,
      date: _date,
      hour: _hour,
    );
    final postsAsync = ref.watch(groupPostsProvider(args));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          groupAsync.maybeWhen(
            data: (g) => g.name,
            orElse: () => 'グループ',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'グループ情報',
            onPressed: () => _showInfoSheet(groupAsync.value),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateBar(),
          _buildHourBar(),
          const Divider(height: 1),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              // 左スワイプ→前日 / 右スワイプ→翌日。
              onHorizontalDragEnd: (details) {
                final v = details.primaryVelocity ?? 0;
                if (v < 0) {
                  _changeDate(-1);
                } else if (v > 0) {
                  _changeDate(1);
                }
              },
              child: postsAsync.when(
                data: _buildPostList,
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('読み込みエラー: $e')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 日付表示バー（移動は本文の左右スワイプで行う）。
  Widget _buildDateBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          Text(_dateLabel,
              style: Theme.of(context).textTheme.titleMedium),
          Text('← スワイプで日付移動 →',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  // 時間移動バー（左右タップ・1時間単位）。
  Widget _buildHourBar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: '1時間前',
          onPressed: _hour > 0 ? () => _changeHour(-1) : null,
        ),
        Expanded(
          child: Center(
            child: Text(
              _hourLabel,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: '1時間後',
          onPressed: _hour < 23 ? () => _changeHour(1) : null,
        ),
      ],
    );
  }

  Widget _buildPostList(List<GroupPost> posts) {
    if (posts.isEmpty) {
      return const Center(
        child: Text('この時間帯の投稿はありません'),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: posts.length,
      itemBuilder: (context, index) => _PostVideoCard(post: posts[index]),
    );
  }

  void _showInfoSheet(Group? group) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (group != null) ...[
                  Text('招待コード',
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  SelectableText(
                    group.inviteCode,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(letterSpacing: 2),
                  ),
                  const Divider(height: 24),
                ],
                Text('メンバー',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Consumer(
                  builder: (context, ref, _) {
                    final membersAsync =
                        ref.watch(groupMembersProvider(widget.groupId));
                    return membersAsync.when(
                      data: (members) => Column(
                        children:
                            members.map((m) => _memberTile(m)).toList(),
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(),
                      ),
                      error: (e, _) => Text('メンバー取得エラー: $e'),
                    );
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('グループを退出'),
                    onPressed: () => _confirmLeave(sheetContext),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _memberTile(AppUser member) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundImage:
            member.iconUrl != null ? NetworkImage(member.iconUrl!) : null,
        child: member.iconUrl == null
            ? Text(member.name.isNotEmpty ? member.name[0] : '?')
            : null,
      ),
      title: Text(member.name),
    );
  }

  Future<void> _confirmLeave(BuildContext sheetContext) async {
    final confirmed = await showDialog<bool>(
      context: sheetContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('グループを退出しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('退出する'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(groupServiceProvider).leaveGroup(widget.groupId);
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('退出に失敗しました: $e')));
    }
  }
}

// 投稿1件のカード。タップで動画を再生/一時停止する。
class _PostVideoCard extends StatefulWidget {
  const _PostVideoCard({required this.post});

  final GroupPost post;

  @override
  State<_PostVideoCard> createState() => _PostVideoCardState();
}

class _PostVideoCardState extends State<_PostVideoCard> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_controller != null) return;
    final controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.post.videoUrl));
    _controller = controller;
    await controller.initialize();
    if (!mounted) return;
    setState(() => _initialized = true);
  }

  Future<void> _toggle() async {
    await _ensureInitialized();
    final controller = _controller;
    if (controller == null) return;
    setState(() {
      controller.value.isPlaying ? controller.pause() : controller.play();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: widget.post.userIconUrl != null
                  ? NetworkImage(widget.post.userIconUrl!)
                  : null,
              child: widget.post.userIconUrl == null
                  ? Text(widget.post.userName.isNotEmpty
                      ? widget.post.userName[0]
                      : '?')
                  : null,
            ),
            title: Text(widget.post.userName),
          ),
          GestureDetector(
            onTap: _toggle,
            child: AspectRatio(
              aspectRatio: (_initialized && controller != null)
                  ? controller.value.aspectRatio
                  : 16 / 9,
              child: (_initialized && controller != null)
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPlayer(controller),
                        if (!controller.value.isPlaying)
                          const Icon(Icons.play_circle_fill,
                              size: 56, color: Colors.white70),
                      ],
                    )
                  : Container(
                      color: Colors.black12,
                      child: const Icon(Icons.play_circle_outline, size: 56),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
