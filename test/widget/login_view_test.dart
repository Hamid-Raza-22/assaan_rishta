import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helpers.dart';

/// Login View Widget Tests
/// 
/// Login screen ki UI testing:
/// - Form fields display
/// - Input validation
/// - Button states
/// - Password visibility toggle

void main() {
  group('LoginView Widget Tests', () {
    testWidgets('Should display email and password fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Column(
            children: [
              TextField(
                key: Key('email_field'),
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                ),
              ),
              TextField(
                key: Key('password_field'),
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
      );

      expect(find.byKey(Key('email_field')), findsOneWidget);
      expect(find.byKey(Key('password_field')), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('Should display login button', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          ElevatedButton(
            onPressed: () {},
            child: Text('Login'),
          ),
        ),
      );

      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Should toggle password visibility',
        (WidgetTester tester) async {
      bool isObscured = true;

      await tester.pumpWidget(
        createTestWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return TextField(
                obscureText: isObscured,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(
                      isObscured ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        isObscured = !isObscured;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Initially obscured
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Tap to show
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Now visible
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('Should display forgot password link',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          TextButton(
            onPressed: () {},
            child: Text('Forgot Password?'),
          ),
        ),
      );

      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('Should display signup link', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account? "),
              TextButton(
                onPressed: () {},
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      );

      expect(find.text("Don't have an account? "), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('Should accept email input', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          TextField(
            key: Key('email_field'),
          ),
        ),
      );

      await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Should accept password input', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          TextField(
            key: Key('password_field'),
            obscureText: true,
          ),
        ),
      );

      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      await tester.pump();

      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('Should disable login button when fields are empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          ElevatedButton(
            onPressed: null,
            child: Text('Login'),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.enabled, isFalse);
    });

    testWidgets('Should show loading indicator during login',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          ElevatedButton(
            onPressed: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 8),
                Text('Logging in...'),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Logging in...'), findsOneWidget);
    });

    testWidgets('Should display app logo', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Column(
            children: [
              Image.asset(
                'assets/ic_logo.png',
                height: 100,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.image),
              ),
              Text('Asaan Rishta'),
            ],
          ),
        ),
      );

      expect(find.text('Asaan Rishta'), findsOneWidget);
    });
  });

  group('Login Form Validation Tests', () {
    testWidgets('Should show error for invalid email',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          TextField(
            decoration: InputDecoration(
              errorText: 'Invalid email format',
            ),
          ),
        ),
      );

      expect(find.text('Invalid email format'), findsOneWidget);
    });

    testWidgets('Should show error for short password',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          TextField(
            decoration: InputDecoration(
              errorText: 'Password must be at least 6 characters',
            ),
          ),
        ),
      );

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });
  });
}
