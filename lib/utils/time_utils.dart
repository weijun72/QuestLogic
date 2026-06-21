/// Converts an ISO timestamp into a relative "time ago" string,
/// e.g. "5m ago", "3h ago", "2d ago".
String timeAgo(String? iso) {
  if (iso == null) return '';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return '';
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

/// Converts an ISO timestamp into a short HH:MM clock string,
/// used in chat list and message timestamps.
String shortTime(String? iso) {
  if (iso == null) return '';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return '';
  return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
}
