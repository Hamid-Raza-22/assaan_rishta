import 'package:assaan_rishta/app/core/models/chat_model/message.dart';
import 'package:assaan_rishta/app/core/utils/chat_message_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deleted history stays hidden while first new message stays visible', () {
    final messages = ['99', '100', '101'].map((sent) => Message(
      fromId: 'owner', toId: 'partner', sent: sent,
      msg: sent, read: '', type: Type.text,
    )).toList();

    expect(ChatMessageFilter.afterDeletion(messages, '100')
        .map((message) => message.sent), ['101']);
  });
}
