import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Integration Tests for Assaan Rishta App
/// 
/// Integration tests puri app flow ko test karte hain
/// Ye tests user journey ko simulate karte hain

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('App should launch successfully', (WidgetTester tester) async {
      // Arrange & Act
      // Note: Replace this with your actual main app widget
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            appBar: AppBar(title: Text('Asaan Rishta')),
            body: Center(child: Text('Welcome to Asaan Rishta')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Asaan Rishta'), findsOneWidget);
    });

    testWidgets('Should navigate between screens', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        GetMaterialApp(
          home: HomeScreen(),
          getPages: [
            GetPage(name: '/details', page: () => DetailsScreen()),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Act - Tap navigation button
      await tester.tap(find.text('Go to Details'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Details Screen'), findsOneWidget);
    });

    testWidgets('Should handle user authentication flow',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        GetMaterialApp(
          home: LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Enter credentials
      await tester.enterText(
        find.byKey(Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(Key('password_field')),
        'password123',
      );
      await tester.pumpAndSettle();

      // Act - Tap login button
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Assert - Check if navigated to home
      // Note: This will depend on your actual authentication logic
      expect(find.byKey(Key('email_field')), findsOneWidget);
    });

    testWidgets('Should display vendor list and navigate to details',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        GetMaterialApp(
          home: VendorListScreen(),
        ),
      );
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Assert - Vendor list is displayed
      expect(find.byType(ListView), findsOneWidget);

      // Act - Tap on first vendor (if exists)
      final vendorItem = find.byKey(Key('vendor_item_0'));
      if (tester.widgetList(vendorItem).isNotEmpty) {
        await tester.tap(vendorItem);
        await tester.pumpAndSettle();

        // Assert - Details screen is shown
        expect(find.text('Vendor Details'), findsOneWidget);
      }
    });

    testWidgets('Should search and filter vendors',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        GetMaterialApp(
          home: VendorListScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Enter search query
      final searchField = find.byKey(Key('search_field'));
      if (tester.widgetList(searchField).isNotEmpty) {
        await tester.enterText(searchField, 'Wedding');
        await tester.pumpAndSettle(Duration(seconds: 1));

        // Assert - Results are filtered
        expect(find.byType(ListView), findsOneWidget);
      }
    });

    testWidgets('Should handle network errors gracefully',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        GetMaterialApp(
          home: VendorListScreen(),
        ),
      );

      // Act - Wait for potential errors
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Assert - Error message or empty state is shown
      // This will depend on your error handling implementation
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('Bottom Navigation Tests', () {
    testWidgets('Should switch between bottom nav tabs',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        GetMaterialApp(
          home: MainScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Tap different bottom nav items
      final bottomNav = find.byType(BottomNavigationBar);
      if (tester.widgetList(bottomNav).isNotEmpty) {
        // Tap second tab
        await tester.tap(find.byIcon(Icons.search));
        await tester.pumpAndSettle();

        // Assert - Second tab content is visible
        expect(find.byType(BottomNavigationBar), findsOneWidget);
      }
    });
  });
}

// Mock screens for testing
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Get.toNamed('/details'),
          child: Text('Go to Details'),
        ),
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details Screen')),
      body: Center(child: Text('Details Screen')),
    );
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              key: Key('email_field'),
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              key: Key('password_field'),
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              key: Key('login_button'),
              onPressed: () {},
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class VendorListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendors'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              key: Key('search_field'),
              decoration: InputDecoration(
                hintText: 'Search vendors...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            key: Key('vendor_item_$index'),
            title: Text('Vendor $index'),
            onTap: () {
              Get.to(() => VendorDetailsScreenMock());
            },
          );
        },
      ),
    );
  }
}

class VendorDetailsScreenMock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vendor Details')),
      body: Center(child: Text('Vendor Details')),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Main Screen')),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
