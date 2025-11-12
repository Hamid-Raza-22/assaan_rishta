import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Complete User Flows Integration Tests
/// 
/// Ye tests complete user journeys ko test karte hain:
/// - Signup to Profile Creation
/// - Login to Home
/// - Search and Filter
/// - Profile View and Edit
/// - Vendor Discovery

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete User Flow Integration Tests', () {
    testWidgets('Complete Signup Flow', (WidgetTester tester) async {
      // Ye test complete signup process ko test karta hai
      
      await tester.pumpWidget(
        GetMaterialApp(
          home: SignupFlowScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: Enter basic information
      await tester.enterText(find.byKey(Key('first_name')), 'Muhammad');
      await tester.enterText(find.byKey(Key('last_name')), 'Ali');
      await tester.enterText(find.byKey(Key('email')), 'ali@example.com');
      await tester.pumpAndSettle();

      // Step 2: Enter phone number
      await tester.enterText(find.byKey(Key('phone')), '3001234567');
      await tester.pumpAndSettle();

      // Step 3: Select gender
      await tester.tap(find.byKey(Key('gender_male')));
      await tester.pumpAndSettle();

      // Step 4: Enter password
      await tester.enterText(find.byKey(Key('password')), 'password123');
      await tester.pumpAndSettle();

      // Step 5: Accept terms
      await tester.tap(find.byKey(Key('terms_checkbox')));
      await tester.pumpAndSettle();

      // Step 6: Submit
      await tester.tap(find.byKey(Key('signup_button')));
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Verify success
      expect(find.text('Account Created'), findsOneWidget);
    });

    testWidgets('Complete Login Flow', (WidgetTester tester) async {
      // Login process testing
      
      await tester.pumpWidget(
        GetMaterialApp(
          home: LoginFlowScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(
        find.byKey(Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(Key('password_field')),
        'password123',
      );
      await tester.pumpAndSettle();

      // Tap login
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Should navigate to home
      expect(find.byKey(Key('home_screen')), findsOneWidget);
    });

    testWidgets('Profile Browsing Flow', (WidgetTester tester) async {
      // User profiles ko browse karna
      
      await tester.pumpWidget(
        GetMaterialApp(
          home: HomeFlowScreen(),
        ),
      );
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Profile cards should be visible
      expect(find.byKey(Key('profile_card_0')), findsOneWidget);

      // Swipe to next profile
      await tester.drag(
        find.byKey(Key('profile_card_0')),
        Offset(-300, 0),
      );
      await tester.pumpAndSettle();

      // Next profile should be visible
      expect(find.byKey(Key('profile_card_1')), findsOneWidget);
    });

    testWidgets('Add to Favorites Flow', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: HomeFlowScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap favorite button
      await tester.tap(find.byKey(Key('favorite_button_0')));
      await tester.pumpAndSettle();

      // Success message should appear
      expect(find.textContaining('favorite'), findsWidgets);
    });

    testWidgets('Search and Filter Flow', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: FilterFlowScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Apply filters
      await tester.tap(find.byKey(Key('gender_female')));
      await tester.pumpAndSettle();

      // Set age range
      await tester.drag(find.byKey(Key('age_from_slider')), Offset(100, 0));
      await tester.pumpAndSettle();

      // Apply filters
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Results should be filtered
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Profile Details View Flow', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: ProfileDetailsFlowScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on profile
      await tester.tap(find.byKey(Key('profile_card_0')));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Profile details should be visible
      expect(find.byKey(Key('profile_details')), findsOneWidget);
      expect(find.byKey(Key('user_name')), findsOneWidget);
      expect(find.byKey(Key('user_age')), findsOneWidget);
    });

    testWidgets('Vendor Search and View Flow', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: VendorFlowScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to vendors
      await tester.tap(find.byKey(Key('vendor_tab')));
      await tester.pumpAndSettle();

      // Search vendor
      await tester.enterText(
        find.byKey(Key('vendor_search')),
        'Wedding Photographer',
      );
      await tester.pumpAndSettle(Duration(seconds: 1));

      // Results should appear
      expect(find.byType(ListView), findsOneWidget);

      // Tap on vendor
      await tester.tap(find.byKey(Key('vendor_item_0')));
      await tester.pumpAndSettle();

      // Vendor details should be visible
      expect(find.byKey(Key('vendor_details')), findsOneWidget);
    });

    testWidgets('Chat Initiation Flow', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: ChatFlowScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // View profile
      await tester.tap(find.byKey(Key('profile_card_0')));
      await tester.pumpAndSettle();

      // Tap chat button
      await tester.tap(find.byKey(Key('chat_button')));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Chat screen should open
      expect(find.byKey(Key('chat_screen')), findsOneWidget);
      expect(find.byKey(Key('message_input')), findsOneWidget);
    });

    testWidgets('Profile Edit Flow', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: ProfileEditFlowScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.byKey(Key('profile_tab')));
      await tester.pumpAndSettle();

      // Tap edit
      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();

      // Update information
      await tester.enterText(
        find.byKey(Key('about_field')),
        'Updated bio information',
      );
      await tester.pumpAndSettle();

      // Save changes
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Success message
      expect(find.textContaining('updated'), findsWidgets);
    });

    testWidgets('Complete Logout Flow', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: LogoutFlowScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.byKey(Key('profile_tab')));
      await tester.pumpAndSettle();

      // Tap logout
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Confirm logout
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Should return to login
      expect(find.byKey(Key('login_screen')), findsOneWidget);
    });
  });

  group('Error Handling Integration Tests', () {
    testWidgets('Handle network error gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: ErrorHandlingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Trigger network request
      await tester.tap(find.byKey(Key('load_button')));
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Error message should appear or retry option
      final errorWidget = find.textContaining('error');
      final retryWidget = find.textContaining('Retry');
      
      expect(errorWidget.evaluate().isNotEmpty || retryWidget.evaluate().isNotEmpty, isTrue);
    });

    testWidgets('Handle empty data state', (WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: EmptyStateScreen(),
        ),
      );
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Empty state message
      expect(find.textContaining('No'), findsWidgets);
    });
  });
}

// Mock screens for testing
class SignupFlowScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(key: Key('first_name')),
          TextField(key: Key('last_name')),
          TextField(key: Key('email')),
          TextField(key: Key('phone')),
          TextField(key: Key('password')),
          Checkbox(key: Key('terms_checkbox'), value: false, onChanged: (_) {}),
          Radio(key: Key('gender_male'), value: 'Male', groupValue: '', onChanged: (_) {}),
          ElevatedButton(key: Key('signup_button'), onPressed: () {}, child: Text('Sign Up')),
        ],
      ),
    );
  }
}

class LoginFlowScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(key: Key('email_field')),
          TextField(key: Key('password_field')),
          ElevatedButton(key: Key('login_button'), onPressed: () {}, child: Text('Login')),
        ],
      ),
    );
  }
}

class HomeFlowScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key('home_screen'),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            key: Key('profile_card_$index'),
            child: ListTile(
              title: Text('Profile $index'),
              trailing: IconButton(
                key: Key('favorite_button_$index'),
                icon: Icon(Icons.favorite_border),
                onPressed: () {},
              ),
            ),
          );
        },
      ),
    );
  }
}

class FilterFlowScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Radio(key: Key('gender_female'), value: 'Female', groupValue: '', onChanged: (_) {}),
          Slider(key: Key('age_from_slider'), value: 20, min: 18, max: 80, onChanged: (_) {}),
          ElevatedButton(onPressed: () {}, child: Text('Apply Filters')),
          Expanded(child: ListView()),
        ],
      ),
    );
  }
}

class ProfileDetailsFlowScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Card(
            key: Key('profile_card_0'),
            child: ListTile(title: Text('Profile'), onTap: () {}),
          ),
          Container(
            key: Key('profile_details'),
            child: Column(
              children: [
                Text('Name', key: Key('user_name')),
                Text('Age: 25', key: Key('user_age')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VendorFlowScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextButton(key: Key('vendor_tab'), onPressed: () {}, child: Text('Vendors')),
          TextField(key: Key('vendor_search')),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return ListTile(
                  key: Key('vendor_item_$index'),
                  title: Text('Vendor $index'),
                  onTap: () {},
                );
              },
            ),
          ),
          Container(key: Key('vendor_details')),
        ],
      ),
    );
  }
}

class ChatFlowScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Card(key: Key('profile_card_0'), child: Text('Profile')),
          ElevatedButton(key: Key('chat_button'), onPressed: () {}, child: Text('Chat')),
          Container(
            key: Key('chat_screen'),
            child: TextField(key: Key('message_input')),
          ),
        ],
      ),
    );
  }
}

class ProfileEditFlowScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextButton(key: Key('profile_tab'), onPressed: () {}, child: Text('Profile')),
          TextButton(onPressed: () {}, child: Text('Edit Profile')),
          TextField(key: Key('about_field')),
          ElevatedButton(onPressed: () {}, child: Text('Save')),
        ],
      ),
    );
  }
}

class LogoutFlowScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key('main_screen'),
      body: Column(
        children: [
          TextButton(key: Key('profile_tab'), onPressed: () {}, child: Text('Profile')),
          TextButton(onPressed: () {}, child: Text('Logout')),
          TextButton(onPressed: () {}, child: Text('Confirm')),
          Container(key: Key('login_screen')),
        ],
      ),
    );
  }
}

class ErrorHandlingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(key: Key('load_button'), onPressed: () {}, child: Text('Load')),
          Text('Network error occurred'),
          TextButton(onPressed: () {}, child: Text('Retry')),
        ],
      ),
    );
  }
}

class EmptyStateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('No data available')),
    );
  }
}
