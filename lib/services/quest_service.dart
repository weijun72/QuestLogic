import 'package:supabase_flutter/supabase_flutter.dart';

class QuestService {
  static final _supabase = Supabase.instance.client;

  static Future<void> acceptQuest({
    required String postId,
    required String posterId,
    required String questTitle,
  }) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null || currentUserId == posterId) {
      throw Exception('Invalid quest acceptance');
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

  static Future<Set<String>> getAcceptedPostIds() async {
    final data = await _supabase.from('quest_acceptances').select('post_id');
    return (data as List).map((a) => a['post_id'] as String).toSet();
  }
}
