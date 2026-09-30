import 'dart:io';

import 'package:assaan_rishta/app/core/models/chat_model/message.dart';
import 'package:assaan_rishta/app/core/models/chat_model/message_adapter.dart';
import 'package:assaan_rishta/app/core/services/hive_message_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

Message message(String from, String to, String sent) => Message(
      fromId: from,
      toId: to,
      sent: sent,
      msg: sent,
      read: '',
      type: Type.text,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  final service = HiveMessageService();

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('chat_cache_test_');
    Hive.init(directory.path);
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(MessageAdapter());
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('owner and partner isolation survives a box reload', () async {
    await service.saveMessages('ownerA', 'partner', [message('ownerA', 'partner', '100')]);
    await service.saveMessages('ownerB', 'partner', [message('ownerB', 'partner', '200')]);

    await service.closeBox('ownerA', 'partner');
    expect((await service.getMessages('ownerA', 'partner')).single.sent, '100');
    expect((await service.getMessages('ownerB', 'partner')).single.sent, '200');
  });

  test('legacy empty-key migration accepts only matching participants', () async {
    final legacy = await Hive.openBox<Message>('messages_');
    await legacy.put('100', message('ownerA', 'partner', '100'));
    await legacy.put('200', message('ownerB', 'partner', '200'));

    expect((await service.getMessages('ownerA', 'partner')).map((m) => m.sent), ['100']);
    expect((await service.getMessages('ownerB', 'partner')).map((m) => m.sent), ['200']);
  });

  test('scoped box ignores a message with different participants', () async {
    final box = await Hive.openBox<Message>('messages_owner_partner');
    await box.put('100', message('stranger', 'partner', '100'));
    await box.put('101', message('owner', 'partner', '101'));

    expect((await service.getMessages('owner', 'partner')).map((m) => m.sent),
        ['101']);
  });

  test('cache reload keeps newest first and preserves all rapid writes', () async {
    await service.saveMessages('owner', 'partner', [message('owner', 'partner', '100')]);
    await service.saveMessages('owner', 'partner', [
      message('owner', 'partner', '101'),
      message('owner', 'partner', '100'),
    ]);
    await service.closeBox('owner', 'partner');

    expect((await service.getMessages('owner', 'partner')).map((m) => m.sent),
        ['101', '100']);
  });

  test('deletion boundary is scoped to owner', () async {
    await service.saveDeletionTime('ownerA', 'partner', '100');
    expect(await service.getDeletionTime('ownerA', 'partner'), '100');
    expect(await service.getDeletionTime('ownerB', 'partner'), isNull);
  });
}
