// ホーム画面。自分のVlog一覧と参加中グループ一覧を表示する。
// ログ作成・グループ作成/参加への導線と、グループ詳細への遷移を担う。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/group.dart';
import '../../models/post.dart';
import 'home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(myPostsProvider);
    final groupsAsync = ref.watch(myGroupsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ホーム')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myPostsProvider);
          ref.invalidate(myGroupsProvider);
          await Future.wait([
            ref.read(myPostsProvider.future),
            ref.read(myGroupsProvider.future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ActionButtons(),
            const SizedBox(height: 24),
            _SectionTitle('自分のVlog'),
            const SizedBox(height: 8),
            _PostsSection(postsAsync: postsAsync),
            const SizedBox(height: 24),
            _SectionTitle('グループ一覧'),
            const SizedBox(height: 8),
            _GroupsSection(groupsAsync: groupsAsync),
          ],
        ),
      ),
    );
  }
}

// ログ作成・グループ作成・グループ参加への導線ボタン。
class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => context.push('/camera'),
            icon: const Icon(Icons.videocam),
            label: const Text('ログ作成'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.push('/group/create'),
            icon: const Icon(Icons.add),
            label: const Text('グループ作成'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.push('/group/join'),
            icon: const Icon(Icons.login),
            label: const Text('グループ参加'),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }
}

// 自分のVlog一覧セクション。非同期の取得状態を表示する。
class _PostsSection extends StatelessWidget {
  const _PostsSection({required this.postsAsync});

  final AsyncValue<List<Post>> postsAsync;

  @override
  Widget build(BuildContext context) {
    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const _EmptyText('まだVlogがありません');
        }
        return Column(
          children: [for (final post in posts) _PostTile(post: post)],
        );
      },
      loading: () => const _LoadingBox(),
      error: (e, _) => _ErrorText('Vlogの取得に失敗しました: $e'),
    );
  }
}

class _PostTile extends StatelessWidget {
  const _PostTile({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final d = post.createdAt.toLocal();
    final dateText =
        '${d.year}/${_two(d.month)}/${_two(d.day)} ${_two(d.hour)}:${_two(d.minute)}';
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.play_arrow)),
        title: Text(dateText),
        subtitle: Text(
          post.videoUrl,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  String _two(int v) => v.toString().padLeft(2, '0');
}

// 参加中グループ一覧セクション。グループ名タップで詳細へ遷移する。
class _GroupsSection extends StatelessWidget {
  const _GroupsSection({required this.groupsAsync});

  final AsyncValue<List<Group>> groupsAsync;

  @override
  Widget build(BuildContext context) {
    return groupsAsync.when(
      data: (groups) {
        if (groups.isEmpty) {
          return const _EmptyText('参加中のグループがありません');
        }
        return Column(
          children: [
            for (final group in groups)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.group),
                  title: Text(group.name),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/group/${group.id}'),
                ),
              ),
          ],
        );
      },
      loading: () => const _LoadingBox(),
      error: (e, _) => _ErrorText('グループの取得に失敗しました: $e'),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(text, style: TextStyle(color: Colors.grey[600])),
    );
  }
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(text, style: const TextStyle(color: Colors.red)),
    );
  }
}
