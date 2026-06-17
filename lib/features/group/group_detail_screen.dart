// グループ詳細画面。指定した日付・時間帯のメンバー全員の投稿を一覧表示する。
// 投稿済みは動画カード、未投稿は枠（プレースホルダー）で表示する。
// 時間移動（左右タップ）／日付移動（左右スワイプ）／メンバー・招待・退出も担当。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../models/app_user.dart';
import '../../models/group.dart';
import 'group_provider.dart';

// メンバー頭文字アバターの色（icon_url が無いとき用）。
const _avatarColors = [
  Color(0xFF4FC3F7),
  Color(0xFF81C784),
  Color(0xFFFFB74D),
  Color(0xFFBA68C8),
  Color(0xFFE57373),
  Color(0xFF4DB6AC),
  Color(0xFF7986CB),
  Color(0xFFF06292),
];

Color _colorFor(String key) =>
    _avatarColors[key.hashCode.abs() % _avatarColors.length];

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

  String get _slotLabel => '${_hour.toString().padLeft(2, '0')}:00';

  @override
  Widget build(BuildContext context) {
    final groupAsync = ref.watch(groupProvider(widget.groupId));
    final membersAsync = ref.watch(groupMembersProvider(widget.groupId));
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
          style: const TextStyle(fontWeight: FontWeight.bold),
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
              // 昨日が左・翌日が右のイメージ。右スワイプ→前日 / 左スワイプ→翌日。
              onHorizontalDragEnd: (details) {
                final v = details.primaryVelocity ?? 0;
                if (v < 0) {
                  _changeDate(1);
                } else if (v > 0) {
                  _changeDate(-1);
                }
              },
              child: _buildContent(membersAsync, postsAsync),
            ),
          ),
        ],
      ),
    );
  }

  // メンバーと投稿の両方が揃ったら、メンバー全員分のカードを表示する。
  Widget _buildContent(
    AsyncValue<List<AppUser>> membersAsync,
    AsyncValue<List<GroupPost>> postsAsync,
  ) {
    if (membersAsync.isLoading || postsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (membersAsync.hasError) {
      return Center(child: Text('メンバーの取得に失敗しました: ${membersAsync.error}'));
    }
    if (postsAsync.hasError) {
      return Center(child: Text('投稿の取得に失敗しました: ${postsAsync.error}'));
    }

    final members = membersAsync.value ?? const [];
    final posts = postsAsync.value ?? const [];
    final postByUser = {for (final p in posts) p.userId: p};

    if (members.isEmpty) {
      return const Center(child: Text('メンバーがいません'));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _MemberAvatarRow(
          members: members,
          postedUserIds: postByUser.keys.toSet(),
        ),
        const SizedBox(height: 16),
        for (final member in members)
          postByUser[member.id] != null
              ? _MemberPostCard(
                  post: postByUser[member.id]!,
                  slotLabel: _slotLabel,
                )
              : _EmptyMemberCard(member: member, slotLabel: _slotLabel),
      ],
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
          Text(_dateLabel, style: Theme.of(context).textTheme.titleMedium),
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
              '$_slotLabel 〜 ${_hour.toString().padLeft(2, '0')}:59',
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
                Text('メンバー', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Consumer(
                  builder: (context, ref, _) {
                    final membersAsync =
                        ref.watch(groupMembersProvider(widget.groupId));
                    return membersAsync.when(
                      data: (members) => Column(
                        children: members.map(_memberTile).toList(),
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
      leading: _Avatar(
        name: member.name,
        iconUrl: member.iconUrl,
        radius: 18,
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

// メンバーの頭文字アバター（icon_url があれば画像）。
class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.name,
    this.iconUrl,
    this.radius = 16,
    this.dimmed = false,
  });

  final String name;
  final String? iconUrl;
  final double radius;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final base = iconUrl != null
        ? CircleAvatar(radius: radius, backgroundImage: NetworkImage(iconUrl!))
        : CircleAvatar(
            radius: radius,
            backgroundColor: _colorFor(name),
            foregroundColor: Colors.white,
            child: Text(
              name.isNotEmpty ? name[0] : '?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.8,
              ),
            ),
          );
    return Opacity(opacity: dimmed ? 0.35 : 1, child: base);
  }
}

// 上部のメンバーアバター横並び。未投稿のメンバーは薄く表示する。
class _MemberAvatarRow extends StatelessWidget {
  const _MemberAvatarRow({required this.members, required this.postedUserIds});

  final List<AppUser> members;
  final Set<String> postedUserIds;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: members.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final member = members[i];
          return _Avatar(
            name: member.name,
            iconUrl: member.iconUrl,
            radius: 22,
            dimmed: !postedUserIds.contains(member.id),
          );
        },
      ),
    );
  }
}

// 投稿済みメンバーのカード。動画を自動再生し、投稿者名・時刻を重ねる。
// 縦で撮影した動画を90度左回転して横向きで表示する。
class _MemberPostCard extends StatefulWidget {
  const _MemberPostCard({required this.post, required this.slotLabel});

  final GroupPost post;
  final String slotLabel;

  @override
  State<_MemberPostCard> createState() => _MemberPostCardState();
}

class _MemberPostCardState extends State<_MemberPostCard> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.post.videoUrl));
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(true);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _initialized = true);
      await controller.play();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  void _toggle() {
    final controller = _controller;
    if (controller == null || !_initialized) return;
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
    return _CardFrame(
      child: GestureDetector(
        onTap: _toggle,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_failed)
              const ColoredBox(
                color: Colors.black87,
                child: Center(
                  child: Icon(Icons.error_outline,
                      color: Colors.white54, size: 40),
                ),
              )
            else if (_initialized && controller != null)
              FittedBox(
                fit: BoxFit.cover,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ),
              )
            else
              const ColoredBox(
                color: Colors.black87,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            _NameOverlay(
              name: widget.post.userName,
              iconUrl: widget.post.userIconUrl,
            ),
            _TimeOverlay(label: widget.slotLabel),
            if (_initialized &&
                controller != null &&
                !controller.value.isPlaying)
              const Center(
                child: Icon(Icons.play_circle_fill,
                    size: 56, color: Colors.white70),
              ),
          ],
        ),
      ),
    );
  }
}

// 未投稿メンバーのプレースホルダーカード。
class _EmptyMemberCard extends StatelessWidget {
  const _EmptyMemberCard({required this.member, required this.slotLabel});

  final AppUser member;
  final String slotLabel;

  @override
  Widget build(BuildContext context) {
    return _CardFrame(
      filled: false,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.hourglass_empty,
                    size: 32, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'まだ投稿していません',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          _NameOverlay(
            name: member.name,
            iconUrl: member.iconUrl,
            dark: false,
          ),
          _TimeOverlay(label: slotLabel, dark: false),
        ],
      ),
    );
  }
}

// カードの共通の枠（角丸・16:10・余白）。filled=false は未投稿用の薄い背景。
class _CardFrame extends StatelessWidget {
  const _CardFrame({required this.child, this.filled = true});

  final Widget child;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: filled ? Colors.black : Colors.grey[200],
            border: filled
                ? null
                : Border.all(color: Colors.grey.shade300, width: 1.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: child,
          ),
        ),
      ),
    );
  }
}

// カード左上の投稿者名＋アバター。
class _NameOverlay extends StatelessWidget {
  const _NameOverlay({required this.name, this.iconUrl, this.dark = true});

  final String name;
  final String? iconUrl;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12,
      top: 12,
      child: Row(
        children: [
          _Avatar(name: name, iconUrl: iconUrl, radius: 14),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              color: dark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              shadows: dark
                  ? const [Shadow(blurRadius: 6, color: Colors.black54)]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

// カード中央の時刻ラベル。
class _TimeOverlay extends StatelessWidget {
  const _TimeOverlay({required this.label, this.dark = true});

  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: TextStyle(
          color: dark ? Colors.white : Colors.grey[500],
          fontSize: 28,
          fontWeight: FontWeight.w900,
          shadows: dark
              ? const [Shadow(blurRadius: 8, color: Colors.black54)]
              : null,
        ),
      ),
    );
  }
}
