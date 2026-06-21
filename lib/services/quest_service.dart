import 'package:supabase_flutter/supabase_flutter.dart';

/// Shared logic for accepting quests and checking acceptance status.
/// Used by HomeScreen and UserProfileScreen to avoid duplicating the
/// same Supabase calls in both places.
class QuestService {
  QuestService._();

  static final _supabase = Supabase.instance.client;

  /// Returns the set of post IDs that have already been accepted by anyone.
  static Future<Set<String>> getAcceptedPostIds() async {
    final data = await _supabase.from('quest_acceptances').select('post_id');
    return (data as List).map((a) => a['post_id'] as String).toSet();
  }

  /// Accepts a quest: records the acceptance and sends an opening message
  /// to the poster so a chat thread exists immediately.
  static Future<void> acceptQuest({
    required String postId,
    required String posterId,
    required String questTitle,
  }) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('You must be signed in to accept a quest');
    }
    if (currentUserId == posterId) {
      throw Exception('You cannot accept your own quest');
    }

    await _supabase.from('quest_acceptances').insert({
      'post_id': postId,
      'acceptor_id': currentUserId,
      'poster_id': posterId,
      'created_at': DateTime.now().toIso8601String(),
    });

    await _supabase.from('messages').insert({
      'sender_id': currentUserId,
      'receiver_id': posterId,
      'content': '👋 I accepted your quest: "$questTitle"! Let\'s connect.',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Deletes a post the current user created.
  static Future<void> deletePost(String postId) async {
    await _supabase.from('posts').delete().eq('id', postId);
  }

  /// Marks an accepted quest as complete.
  static Future<void> completeQuest(String acceptanceId) async {
    await _supabase
        .from('quest_acceptances')
        .update({'completed': true})
        .eq('id', acceptanceId);
  }
}
