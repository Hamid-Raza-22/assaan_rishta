import 'package:assaan_rishta/app/core/models/chat_model/message.dart';
import 'package:assaan_rishta/app/viewmodels/chat_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('switching chat clears messages and optimistic state before loading', () {
    final model = ChatViewModel();
    model.messages.add(Message(
      fromId: 'owner', toId: 'chatA', sent: '100',
      msg: 'old', read: '', type: Type.text,
    ));
    model.hasCachedMessages.value = true;
    model.currentChatDeletionTime.value = '50';

    model.resetChatState();

    expect(model.messages, isEmpty);
    expect(model.hasCachedMessages.value, isFalse);
    expect(model.currentChatDeletionTime.value, isNull);
  });
}
