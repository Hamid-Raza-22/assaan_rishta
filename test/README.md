# Assaan Rishta Testing Guide

Ye guide aapko bataye gi ke apne Flutter app ki testing kaise karni hai.

## Testing Types

### 1. Unit Tests (یونٹ ٹیسٹس)
Unit tests individual functions aur classes ko test karte hain bina UI ke.

**Location:** `test/unit/`

**Run karne ka tareeqa:**
```bash
flutter test test/unit/
```

**Example:**
```dart
test('Email validation should work correctly', () {
  const validEmail = 'test@example.com';
  final isValid = _isValidEmail(validEmail);
  expect(isValid, isTrue);
});
```

### 2. Widget Tests (ویجٹ ٹیسٹس)
Widget tests UI components ko test karte hain.

**Location:** `test/widget/`

**Run karne ka tareeqa:**
```bash
flutter test test/widget/
```

**Example:**
```dart
testWidgets('Should display vendor name', (WidgetTester tester) async {
  await tester.pumpWidget(MyWidget());
  expect(find.text('Vendor Name'), findsOneWidget);
});
```

### 3. Integration Tests (انٹیگریشن ٹیسٹس)
Integration tests puri app flow ko test karte hain.

**Location:** `integration_test/`

**Run karne ka tareeqa:**
```bash
flutter test integration_test/app_test.dart
```

**Device pe run karne ke liye:**
```bash
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart
```

## Project Structure

```
test/
├── helpers/
│   ├── test_helpers.dart          # Test helper functions
│   └── mock_data.dart              # Mock data for testing
├── mocks/
│   └── mock_services.dart          # Mock services (Firebase, etc)
├── unit/
│   ├── viewmodels/                 # ViewModel tests
│   │   └── login_viewmodel_test.dart
│   └── utils/                      # Utility function tests
│       └── string_utils_test.dart
└── widget/
    ├── vendor_details_view_test.dart  # Widget tests
    └── custom_button_test.dart

integration_test/
└── app_test.dart                   # Integration tests
```

## Commands

### Sab tests chalana
```bash
flutter test
```

### Specific test file chalana
```bash
flutter test test/unit/viewmodels/login_viewmodel_test.dart
```

### Coverage report generate karna
```bash
flutter test --coverage
```

### Coverage report dekhna (HTML format)
```bash
# Install genhtml
# Windows: Install from http://ltp.sourceforge.net/coverage/lcov.php
# Mac: brew install lcov
# Linux: sudo apt-get install lcov

genhtml coverage/lcov.info -o coverage/html
# Then open coverage/html/index.html in browser
```

### Integration tests device pe chalana
```bash
# Android
flutter drive --target=integration_test/app_test.dart

# iOS Simulator
flutter drive --target=integration_test/app_test.dart
```

## Test Writing Guidelines

### Unit Test Example
```dart
group('Login Validation Tests', () {
  test('Should validate email format', () {
    // Arrange
    const email = 'test@example.com';
    
    // Act
    final result = validateEmail(email);
    
    // Assert
    expect(result, isTrue);
  });
});
```

### Widget Test Example
```dart
testWidgets('Button tap should trigger callback', (tester) async {
  bool tapped = false;
  
  await tester.pumpWidget(
    MaterialApp(
      home: ElevatedButton(
        onPressed: () => tapped = true,
        child: Text('Tap'),
      ),
    ),
  );
  
  await tester.tap(find.text('Tap'));
  expect(tapped, isTrue);
});
```

### Integration Test Example
```dart
testWidgets('Complete user flow', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Login
  await tester.enterText(find.byKey(Key('email')), 'test@example.com');
  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();
  
  // Verify home screen
  expect(find.text('Home'), findsOneWidget);
});
```

## Best Practices

1. **Test Naming:** Test ka naam clear aur descriptive hona chahiye
   ```dart
   test('Should return error when email is invalid', () {});
   ```

2. **AAA Pattern:** Arrange, Act, Assert pattern follow karein
   ```dart
   test('example', () {
     // Arrange - Setup
     final data = 'test';
     
     // Act - Execute
     final result = process(data);
     
     // Assert - Verify
     expect(result, equals('expected'));
   });
   ```

3. **Mock External Dependencies:** Firebase, APIs ko mock karein
   ```dart
   final mockAuth = MockFirebaseAuth();
   when(mockAuth.signIn()).thenReturn(mockUser);
   ```

4. **Test Isolation:** Har test independent hona chahiye
   ```dart
   setUp(() {
     // Initialize
   });
   
   tearDown(() {
     // Cleanup
   });
   ```

5. **Use Test Helpers:** Common operations ke liye helpers use karein

## Common Matchers

```dart
expect(value, equals(expected));
expect(value, isTrue);
expect(value, isFalse);
expect(value, isNull);
expect(value, isNotNull);
expect(list, isEmpty);
expect(list, isNotEmpty);
expect(list, contains(item));
expect(finder, findsOneWidget);
expect(finder, findsNothing);
expect(finder, findsNWidgets(3));
```

## Dependencies

Testing ke liye ye dependencies install hain:

- `flutter_test`: Flutter's testing framework
- `mockito`: Mocking library
- `mocktail`: Alternative mocking library
- `fake_cloud_firestore`: Firebase Firestore mocking
- `firebase_auth_mocks`: Firebase Auth mocking
- `network_image_mock`: Network images ke liye mock
- `integration_test`: Integration testing

## Troubleshooting

### Issue: Tests fail with network errors
**Solution:** Network calls ko mock karein ya `mockNetworkImagesFor` use karein

### Issue: GetX tests failing
**Solution:** `Get.testMode = true` aur `Get.reset()` use karein

### Issue: Firebase not initialized
**Solution:** Mock Firebase services use karein

### Issue: Widget not found in test
**Solution:** `await tester.pumpAndSettle()` use karein

## CI/CD Integration

GitHub Actions ke liye:

```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter test --coverage
```

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Flutter Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Mockito Documentation](https://pub.dev/packages/mockito)

## Support

Testing mein koi issue ho toh:
1. Documentation check karein
2. Error messages ko carefully padhein
3. Stack Overflow pe search karein
4. Team se madad lein

---

**Happy Testing! 🧪✅**
