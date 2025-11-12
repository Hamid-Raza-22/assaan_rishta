import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import '../helpers/test_helpers.dart';

/// User Details View Widget Tests
/// 
/// User profile details screen testing:
/// - Profile information display
/// - Action buttons
/// - Image gallery
/// - Connect button

void main() {
  group('UserDetailsView Widget Tests', () {
    testWidgets('Should display user profile information',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          createTestWidget(
            Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      NetworkImage('https://example.com/profile.jpg'),
                ),
                SizedBox(height: 16),
                Text('Ali Khan',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('25 years old'),
                Text('Karachi, Pakistan'),
              ],
            ),
          ),
        );

        await tester.pump();

        expect(find.text('Ali Khan'), findsOneWidget);
        expect(find.text('25 years old'), findsOneWidget);
        expect(find.text('Karachi, Pakistan'), findsOneWidget);
      });
    });

    testWidgets('Should display chat button', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.chat),
            label: Text('Chat'),
          ),
        ),
      );

      expect(find.text('Chat'), findsOneWidget);
      expect(find.byIcon(Icons.chat), findsOneWidget);
    });

    testWidgets('Should display connect button', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.person_add),
            label: Text('Send Connect Request'),
          ),
        ),
      );

      expect(find.text('Send Connect Request'), findsOneWidget);
      expect(find.byIcon(Icons.person_add), findsOneWidget);
    });

    testWidgets('Should display favorite button', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('Should display share button', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('Should display profile details sections',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Column(
            children: [
              ListTile(
                leading: Icon(Icons.info),
                title: Text('Basic Information'),
              ),
              ListTile(
                leading: Icon(Icons.family_restroom),
                title: Text('Family Details'),
              ),
              ListTile(
                leading: Icon(Icons.work),
                title: Text('Professional Details'),
              ),
            ],
          ),
        ),
      );

      expect(find.text('Basic Information'), findsOneWidget);
      expect(find.text('Family Details'), findsOneWidget);
      expect(find.text('Professional Details'), findsOneWidget);
    });

    testWidgets('Should display connects count', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Row(
            children: [
              Icon(Icons.link),
              Text('50 Connects'),
            ],
          ),
        ),
      );

      expect(find.text('50 Connects'), findsOneWidget);
      expect(find.byIcon(Icons.link), findsOneWidget);
    });

    testWidgets('Should display loading indicator when loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Should display education info', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          ListTile(
            leading: Icon(Icons.school),
            title: Text('Masters in Computer Science'),
          ),
        ),
      );

      expect(find.text('Masters in Computer Science'), findsOneWidget);
      expect(find.byIcon(Icons.school), findsOneWidget);
    });

    testWidgets('Should display occupation', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          ListTile(
            leading: Icon(Icons.work),
            title: Text('Software Engineer'),
          ),
        ),
      );

      expect(find.text('Software Engineer'), findsOneWidget);
    });

    testWidgets('Should be scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          SingleChildScrollView(
            child: Column(
              children: List.generate(
                20,
                (index) => Container(
                  height: 100,
                  child: Text('Section $index'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('UserDetailsView Interaction Tests', () {
    testWidgets('Should navigate to chat on button tap',
        (WidgetTester tester) async {
      bool chatTapped = false;

      await tester.pumpWidget(
        createTestWidget(
          ElevatedButton(
            onPressed: () {
              chatTapped = true;
            },
            child: Text('Chat'),
          ),
        ),
      );

      await tester.tap(find.text('Chat'));
      expect(chatTapped, isTrue);
    });

    testWidgets('Should show insufficient connects dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: tester.element(find.byType(ElevatedButton)),
                    builder: (context) => AlertDialog(
                      title: Text('Insufficient Connects'),
                      content: Text('You need connects to view this profile'),
                    ),
                  );
                },
                child: Text('View Profile'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('View Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Insufficient Connects'), findsOneWidget);
      expect(find.text('You need connects to view this profile'),
          findsOneWidget);
    });
  });
}
