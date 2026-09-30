/// Message IDs are numeric milliseconds because existing chat sorting and
/// deletion filters parse `sent` as a millisecond timestamp.
class ChatMessageId {
  static int _last = 0;

  static String next({int? after}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final minimum = after == null ? _last : (after > _last ? after : _last);
    _last = now > minimum ? now : minimum + 1;
    return _last.toString();
  }
}
