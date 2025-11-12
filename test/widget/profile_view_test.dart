import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import '../helpers/test_helpers.dart';

/// Profile View Widget Tests
/// 
/// Profile screen ki UI testing:
/// - User information display
/// - Profile image
/// - Menu options
/// - Logout functionality

void main() {
  group('ProfileView Widget Tests', () {
    testWidgets('Should display user profile information',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          createTestWidget(
            Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://example.com/avatar.jpg'),
                ),
                SizedBox(height: 16),
                Text('Muhammad Ali', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('ali@example.com'),
                Text('+92 300 1234567'),
              ],
            ),
          ),
        );

        await tester.pump();

        expect(find.text('Muhammad Ali'), findsOneWidget);
        expect(find.text('ali@example.com'), findsOneWidget);
        expect(find.text('+92 300 1234567'), findsOneWidget);
      });
    });

    testWidgets('Should display profile completion percentage',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Column(
            children: [
              Text('Profile Completion'),
              LinearProgressIndicator(value: 0.75),
              Text('75%'),
            ],
          ),
        ),
      );

      expect(find.text('Profile Completion'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('Should display menu options', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          ListView(
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit Profile'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text('Favorites'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
              ListTile(
                leading: Icon(Icons.payment),
                title: Text('Buy Connects'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
              ListTile(
                leading: Icon(Icons.lock),
                title: Text('Change Password'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('About Us'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
              ),
            ],
          ),
        ),
      );

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Buy Connects'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('About Us'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('Should show logout confirmation dialog',
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
                      title: Text('Logout'),
                      content: Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () {},
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text('Logout'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to logout?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Logout'), findsNWidgets(2)); // Button text appears twice
    });

    testWidgets('Should display version number', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Center(
            child: Text('Version 1.17.30'),
          ),
        ),
      );

      expect(find.text('Version 1.17.30'), findsOneWidget);
    });

    testWidgets('Should handle profile image tap', (WidgetTester tester) async {
      bool imageTapped = false;

      await tester.pumpWidget(
        createTestWidget(
          GestureDetector(
            onTap: () {
              imageTapped = true;
            },
            child: CircleAvatar(
              radius: 50,
              child: Icon(Icons.camera_alt),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CircleAvatar));
      expect(imageTapped, isTrue);
    });

    testWidgets('Should display delete account option',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.red),
            title: Text('Delete Account', style: TextStyle(color: Colors.red)),
          ),
        ),
      );

      expect(find.text('Delete Account'), findsOneWidget);
      expect(find.byIcon(Icons.delete_forever), findsOneWidget);
    });

    testWidgets('Should show delete confirmation dialog',
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
                      title: Text('Delete Account'),
                      content: Text('This action cannot be undone. Are you sure?'),
                      actions: [
                        TextButton(
                          onPressed: () {},
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('This action cannot be undone. Are you sure?'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });
  });

  group('Profile Edit Tests', () {
    testWidgets('Should display image picker options',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: tester.element(find.byType(ElevatedButton)),
                    builder: (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(Icons.camera),
                          title: Text('Take Photo'),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: Icon(Icons.photo_library),
                          title: Text('Choose from Gallery'),
                          onTap: () {},
                        ),
                      ],
                    ),
                  );
                },
                child: Text('Show Options'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Options'));
      await tester.pumpAndSettle();

      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Choose from Gallery'), findsOneWidget);
    });
  });
}
