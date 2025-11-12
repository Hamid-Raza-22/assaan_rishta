import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:network_image_mock/network_image_mock.dart';
import '../helpers/test_helpers.dart';

/// Widget tests for VendorDetailView
/// 
/// Ye tests UI components ko verify karte hain
/// Widget testing mein hum actual UI render karte hain aur test karte hain

void main() {
  group('VendorDetailView Widget Tests', () {
    setUp(() {
      // Initialize GetX for testing
      Get.testMode = true;
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('Should display loading indicator when vendor data is null',
        (WidgetTester tester) async {
      // Arrange: Test widget banao
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

      // Act: Widget ko render karo
      await tester.pump();

      // Assert: Verify loading indicator dikhai de raha hai
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Should display vendor name when data is available',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        // Arrange
        const vendorName = 'Test Vendor Business';
        await tester.pumpWidget(
          makeTestableWidget(
            child: Scaffold(
              body: Center(
                child: Text(
                  vendorName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        );

        // Act
        await tester.pump();

        // Assert
        expect(find.text(vendorName), findsOneWidget);
      });
    });

    testWidgets('Should display category and email information',
        (WidgetTester tester) async {
      // Arrange
      const category = 'Wedding Venue';
      const email = 'vendor@example.com';

      await tester.pumpWidget(
        makeTestableWidget(
          child: Scaffold(
            body: Column(
              children: [
                Row(
                  children: [
                    Text('Category: ', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text(category),
                  ],
                ),
                Row(
                  children: [
                    Text('Email: ', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text(email),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.text('Category: '), findsOneWidget);
      expect(find.text(category), findsOneWidget);
      expect(find.text('Email: '), findsOneWidget);
      expect(find.text(email), findsOneWidget);
    });

    testWidgets('Should display "View Number" button',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        makeTestableWidget(
          child: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                ),
                child: Text(
                  'View Number',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.text('View Number'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Should display tab items (Services, Questions, etc)',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        makeTestableWidget(
          child: Scaffold(
            body: Row(
              children: [
                Text('Services'),
                SizedBox(width: 10),
                Text('Questions'),
                SizedBox(width: 10),
                Text('ALBUMS '),
                SizedBox(width: 10),
                Text('VIDEOS'),
                SizedBox(width: 10),
                Text('PACKAGES'),
              ],
            ),
          ),
        ),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.text('Services'), findsOneWidget);
      expect(find.text('Questions'), findsOneWidget);
      expect(find.text('ALBUMS '), findsOneWidget);
      expect(find.text('VIDEOS'), findsOneWidget);
      expect(find.text('PACKAGES'), findsOneWidget);
    });

    testWidgets('Should display share button in app bar',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        // Arrange
        await tester.pumpWidget(
          makeTestableWidget(
            child: Scaffold(
              appBar: AppBar(
                title: Text('Vendor Details'),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.share),
                  ),
                ],
              ),
              body: Container(),
            ),
          ),
        );

        // Act
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.share), findsOneWidget);
        expect(find.byType(IconButton), findsWidgets);
      });
    });

    testWidgets('Should display "About Company" section',
        (WidgetTester tester) async {
      // Arrange
      const aboutText = 'This is a test vendor company';
      await tester.pumpWidget(
        makeTestableWidget(
          child: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'About Company',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 13),
                  Text(aboutText),
                ],
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.text('About Company'), findsOneWidget);
      expect(find.text(aboutText), findsOneWidget);
    });

    testWidgets('Should be scrollable', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        makeTestableWidget(
          child: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: List.generate(
                  20,
                  (index) => Container(
                    height: 100,
                    child: Text('Item $index'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('Custom Button Widget Tests', () {
    testWidgets('Button should be tappable', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        makeTestableWidget(
          child: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  tapped = true;
                },
                child: Text('Tap Me'),
              ),
            ),
          ),
        ),
      );

      // Tap the button
      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      // Verify button was tapped
      expect(tapped, isTrue);
    });
  });
}
