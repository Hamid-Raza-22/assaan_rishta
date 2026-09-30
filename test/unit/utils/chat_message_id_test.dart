import 'package:flutter_test/flutter_test.dart';
import 'package:assaan_rishta/app/core/utils/chat_message_id.dart';

void main() {
  test('rapid message IDs remain unique and sortable as milliseconds', () {
    final ids = List.generate(100, (_) => ChatMessageId.next());
    expect(ids.toSet().length, ids.length);
    for (var i = 1; i < ids.length; i++) {
      expect(int.parse(ids[i]), greaterThan(int.parse(ids[i - 1])));
    }
  });

  test('first new message is later than the deletion boundary', () {
    final boundary = DateTime.now().millisecondsSinceEpoch + 5;
    expect(int.parse(ChatMessageId.next(after: boundary)), greaterThan(boundary));
  });
}
