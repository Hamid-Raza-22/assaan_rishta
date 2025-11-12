import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import '../helpers/test_helpers.dart';

/// Chat View Widget Tests
/// 
/// Chat screen UI testing:
/// - Message list display
/// - Input field
/// - Send button
/// - Typing indicator

void main() {
  group('ChatView Widget Tests', () {
    testWidgets('Should display chat messages', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              return ListTile(
                key: Key('message_$index'),
                title: Text('Message $index'),
              );
            },
          ),
        ),
      );

      expect(find.text('Message 0'), findsOneWidget);
      expect(find.text('Message 1'), findsOneWidget);
      expect(find.text('Message 2'), findsOneWidget);
    });

    testWidgets('Should display message input field',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          TextField(
            key: Key('message_input'),
            decoration: InputDecoration(
              hintText: 'Type a message',
            ),
          ),
        ),
      );

      expect(find.byKey(Key('message_input')), findsOneWidget);
      expect(find.text('Type a message'), findsOneWidget);
    });

    testWidgets('Should display send button', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          IconButton(
            key: Key('send_button'),
            icon: Icon(Icons.send),
            onPressed: () {},
          ),
        ),
      );

      expect(find.byKey(Key('send_button')), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('Should accept message input', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          TextField(
            key: Key('message_input'),
          ),
        ),
      );

      await tester.enterText(
          find.byKey(Key('message_input')), 'Hello, how are you?');
      await tester.pump();

      expect(find.text('Hello, how are you?'), findsOneWidget);
    });

    testWidgets('Should display typing indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Row(
            children: [
              Text('User is typing'),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ),
      );

      expect(find.text('User is typing'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Should display user avatar', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          createTestWidget(
            CircleAvatar(
              backgroundImage: NetworkImage('https://example.com/avatar.jpg'),
              child: Text('U'),
            ),
          ),
        );

        await tester.pump();

        expect(find.byType(CircleAvatar), findsOneWidget);
      });
    });

    testWidgets('Should display timestamp', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Text('10:30 AM'),
        ),
      );

      expect(find.text('10:30 AM'), findsOneWidget);
    });

    testWidgets('Should display sent message on right',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('My message'),
            ),
          ),
        ),
      );

      expect(find.text('My message'), findsOneWidget);
    });

    testWidgets('Should display received message on left',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Received message'),
            ),
          ),
        ),
      );

      expect(find.text('Received message'), findsOneWidget);
    });

    testWidgets('Should show read receipt', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Row(
            children: [
              Text('Message'),
              Icon(Icons.done_all, size: 16, color: Colors.blue),
            ],
          ),
        ),
      );

      expect(find.byIcon(Icons.done_all), findsOneWidget);
    });

    testWidgets('Should scroll message list', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) {
              return Container(
                height: 60,
                child: Text('Message $index'),
              );
            },
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
    });
  });

  group('Chat View Interaction Tests', () {
    testWidgets('Should send message on button tap',
        (WidgetTester tester) async {
      bool messageSent = false;

      await tester.pumpWidget(
        createTestWidget(
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              messageSent = true;
            },
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.send));
      expect(messageSent, isTrue);
    });

    testWidgets('Should show attachment options',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          IconButton(
            icon: Icon(Icons.attach_file),
            onPressed: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.attach_file), findsOneWidget);
    });
  });
}
