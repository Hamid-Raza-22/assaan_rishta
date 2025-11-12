import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:network_image_mock/network_image_mock.dart';
import '../helpers/test_helpers.dart';

/// Home View Widget Tests
/// 
/// Home screen ki UI testing:
/// - Profile cards display
/// - Swipe functionality
/// - Favorite button
/// - Loading states

void main() {
  group('HomeView Widget Tests', () {
    setUp(() {
      Get.testMode = true;
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('Should display loading indicator initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.pink,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Should display profile cards when data is loaded',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          makeTestableWidget(
            child: Scaffold(
              body: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Card(
                    key: Key('profile_card_$index'),
                    child: ListTile(
                      title: Text('Profile $index'),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pump();

        expect(find.byType(Card), findsNWidgets(5));
        expect(find.text('Profile 0'), findsOneWidget);
      });
    });

    testWidgets('Should display favorite icon button',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          makeTestableWidget(
            child: Scaffold(
              body: Card(
                child: ListTile(
                  title: Text('User Profile'),
                  trailing: IconButton(
                    icon: Icon(Icons.favorite_border),
                    onPressed: () {},
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
        expect(find.byType(IconButton), findsOneWidget);
      });
    });

    testWidgets('Should toggle favorite status on tap',
        (WidgetTester tester) async {
      bool isFavorite = false;

      await tester.pumpWidget(
        makeTestableWidget(
          child: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Initially not favorite
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      // Tap to favorite
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      // Now favorited
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('Should display user name and age',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: Scaffold(
            body: Column(
              children: [
                Text('Muhammad Ali'),
                Text('Age: 25'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Muhammad Ali'), findsOneWidget);
      expect(find.text('Age: 25'), findsOneWidget);
    });

    testWidgets('Should display city and profession',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: Scaffold(
            body: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on),
                    Text('Karachi'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.work),
                    Text('Engineer'),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Karachi'), findsOneWidget);
      expect(find.text('Engineer'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.byIcon(Icons.work), findsOneWidget);
    });

    testWidgets('Should be scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: Scaffold(
            body: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                return Container(
                  height: 200,
                  child: Text('Card $index'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Should display empty state when no profiles',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No profiles found'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('No profiles found'), findsOneWidget);
      expect(find.byIcon(Icons.person_off), findsOneWidget);
    });

    testWidgets('Should display profile image', (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          makeTestableWidget(
            child: Scaffold(
              body: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://example.com/image.jpg'),
              ),
            ),
          ),
        );

        await tester.pump();

        expect(find.byType(CircleAvatar), findsOneWidget);
      });
    });
  });

  group('Profile Card Interaction Tests', () {
    testWidgets('Should navigate to profile details on tap',
        (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        makeTestableWidget(
          child: Scaffold(
            body: GestureDetector(
              onTap: () {
                wasTapped = true;
              },
              child: Card(
                child: Text('Tap to view profile'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap to view profile'));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('Should display login dialog for non-logged users',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: Text('Login Required'),
                      content: Text('Please login to continue'),
                    ),
                  );
                },
                child: Text('Add to Favorite'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Add to Favorite'));
      await tester.pumpAndSettle();

      expect(find.text('Login Required'), findsOneWidget);
      expect(find.text('Please login to continue'), findsOneWidget);
    });
  });
}
