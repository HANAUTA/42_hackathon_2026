// ダッシュボード画面の集計データを取得するProvider群。

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase_client.dart';

class DashboardStats {
  const DashboardStats({
    required this.totalPlays,
    required this.totalPosts,
    required this.avgGroupsPerUser,
    required this.avgRetakeCount,
  });

  final int totalPlays;
  final int totalPosts;
  final double avgGroupsPerUser;
  final double avgRetakeCount;
}

final dashboardStatsProvider =
    FutureProvider.autoDispose<DashboardStats>((ref) async {
  final playsFuture = supabase
      .from('analytics_events')
      .select('id')
      .eq('event_name', 'video_played')
      .count();
  final postsFuture = supabase
      .from('analytics_events')
      .select('id')
      .eq('event_name', 'video_posted')
      .count();
  final retakeFuture = supabase
      .from('analytics_events')
      .select('properties')
      .eq('event_name', 'video_posted');
  final membersFuture = supabase.from('group_members').select('user_id');

  final playsResult = await playsFuture;
  final postsResult = await postsFuture;
  final postRows = await retakeFuture;
  final memberRows = await membersFuture;

  final totalPlays = playsResult.count;
  final totalPosts = postsResult.count;
  double avgRetake = 0;
  if (postRows.isNotEmpty) {
    int sum = 0;
    int count = 0;
    for (final row in postRows) {
      final props = row['properties'] as Map<String, dynamic>?;
      if (props != null && props['retake_count'] != null) {
        sum += (props['retake_count'] as num).toInt();
        count++;
      }
    }
    if (count > 0) avgRetake = sum / count;
  }

  double avgGroups = 0;
  if (memberRows.isNotEmpty) {
    final userGroups = <String, int>{};
    for (final row in memberRows) {
      final uid = row['user_id'] as String;
      userGroups[uid] = (userGroups[uid] ?? 0) + 1;
    }
    final total =
        userGroups.values.fold<int>(0, (sum, count) => sum + count);
    avgGroups = total / userGroups.length;
  }

  return DashboardStats(
    totalPlays: totalPlays,
    totalPosts: totalPosts,
    avgGroupsPerUser: avgGroups,
    avgRetakeCount: avgRetake,
  );
});
