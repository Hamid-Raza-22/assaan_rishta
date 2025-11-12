# Assaan Rishta - Testing Guide (اردو/اُردو رہنمائی)

## تعارف (Introduction)

یہ گائیڈ آپ کو بتائے گی کہ Assaan Rishta app کی testing کیسے کرنی ہے۔

## Testing کی اقسام (Types of Tests)

### 1. یونٹ ٹیسٹس (Unit Tests)

**کیا ہیں؟** یونٹ ٹیسٹس چھوٹے functions اور methods کو test کرتے ہیں۔

**مثال:**
- Email validation check کرنا
- Password strength check کرنا
- Date formatting check کرنا

**کیسے چلائیں:**
```bash
flutter test test/unit/
```

### 2. ویجٹ ٹیسٹس (Widget Tests)

**کیا ہیں؟** یہ tests UI components (buttons, text fields, etc) کو test کرتے ہیں۔

**مثال:**
- Button click ہو رہا ہے یا نہیں
- Text field میں text enter ہو رہا ہے یا نہیں
- صحیح text display ہو رہا ہے یا نہیں

**کیسے چلائیں:**
```bash
flutter test test/widget/
```

### 3. انٹیگریشن ٹیسٹس (Integration Tests)

**کیا ہیں؟** یہ tests پوری app کی flow کو test کرتے ہیں (جیسے user کرے گا)۔

**مثال:**
- Login → Home Screen → Vendor Details
- Search → Results → Details
- Complete booking flow

**کیسے چلائیں:**
```bash
flutter test integration_test/
```

## Step-by-Step Testing شروع کریں

### قدم 1: Dependencies Install کریں

```bash
flutter pub get
```

یہ command سب testing packages install کر دے گا۔

### قدم 2: پہلا Test چلائیں

سب سے آسان test چلائیں:

```bash
flutter test test/unit/utils/string_utils_test.dart
```

Output میں آپ کو دیکھنا چاہیے:
```
✓ Should capitalize first letter of string
✓ Should slugify string correctly
✓ Should format phone number
All tests passed!
```

### قدم 3: Widget Test چلائیں

```bash
flutter test test/widget/custom_button_test.dart
```

### قدم 4: سب Tests ایک ساتھ چلائیں

```bash
flutter test
```

## اپنا پہلا Test لکھیں

### Example 1: Simple Unit Test

File: `test/unit/my_first_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Test group بنائیں
  group('میرا پہلا test group', () {
    
    // پہلا test
    test('جمع کا test', () {
      // Arrange - تیاری کریں
      final a = 5;
      final b = 3;
      
      // Act - action لیں
      final result = a + b;
      
      // Assert - check کریں کہ result صحیح ہے
      expect(result, equals(8));
    });
    
    // دوسرا test
    test('String کا test', () {
      final name = 'Ali';
      expect(name.length, equals(3));
      expect(name.contains('A'), isTrue);
    });
  });
}
```

اب اسے چلائیں:
```bash
flutter test test/unit/my_first_test.dart
```

### Example 2: Widget Test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Button test', (WidgetTester tester) async {
    // Widget بنائیں
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            onPressed: () {},
            child: Text('کلک کریں'),
          ),
        ),
      ),
    );
    
    // Check کریں کہ button موجود ہے
    expect(find.text('کلک کریں'), findsOneWidget);
    
    // Button پر click کریں
    await tester.tap(find.text('کلک کریں'));
    await tester.pump();
  });
}
```

## عام Commands

### 1. سب tests چلانا
```bash
flutter test
```

### 2. Specific folder کے tests
```bash
flutter test test/unit/
flutter test test/widget/
```

### 3. ایک specific file کا test
```bash
flutter test test/unit/viewmodels/login_viewmodel_test.dart
```

### 4. Watch mode (auto-run on changes)
```bash
flutter test --watch
```

### 5. Coverage report (کتنا code test ہوا)
```bash
flutter test --coverage
```

## Test Results سمجھیں

### ✅ Pass (کامیاب)
```
✓ Should validate email correctly
```
یعنی test pass ہو گیا!

### ❌ Fail (ناکام)
```
✗ Should validate email correctly
Expected: true
Actual: false
```
یعنی test fail ہو گیا - کوئی مسئلہ ہے!

## عام مسائل اور حل (Troubleshooting)

### مسئلہ 1: "Cannot find package"
**حل:**
```bash
flutter pub get
flutter clean
flutter pub get
```

### مسئلہ 2: GetX tests fail ہو رہے ہیں
**حل:** Test میں یہ add کریں:
```dart
setUp(() {
  Get.testMode = true;
});

tearDown(() {
  Get.reset();
});
```

### مسئلہ 3: Network image load نہیں ہو رہی
**حل:** `mockNetworkImagesFor` use کریں:
```dart
mockNetworkImagesFor(() async {
  await tester.pumpWidget(MyWidget());
});
```

### مسئلہ 4: Widget نہیں مل رہا
**حل:** `pumpAndSettle` use کریں:
```dart
await tester.pumpWidget(MyWidget());
await tester.pumpAndSettle(); // یہ add کریں
```

## ٹیسٹنگ کے اصول (Best Practices)

### 1. Test کا نام واضح رکھیں
✅ اچھا: `test('Should validate email format correctly', () {})`
❌ برا: `test('test1', () {})`

### 2. AAA Pattern استعمال کریں
```dart
test('example', () {
  // Arrange (تیاری)
  final input = 'test';
  
  // Act (عمل)
  final result = process(input);
  
  // Assert (تصدیق)
  expect(result, equals('expected'));
});
```

### 3. ہر test الگ ہونا چاہیے
ایک test دوسرے test پر منحصر نہیں ہونا چاہیے۔

### 4. Real services کو mock کریں
Firebase, APIs وغیرہ کو mock کریں تاکہ tests تیز چلیں۔

## Vendor Detail View Testing Example

```dart
testWidgets('Vendor name display ہونا چاہیے', (tester) async {
  // Arrange
  final vendorName = 'Test Vendor';
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Text(vendorName),
      ),
    ),
  );
  
  // Act
  await tester.pump();
  
  // Assert
  expect(find.text(vendorName), findsOneWidget);
});
```

## Integration Test Example (مکمل flow)

```dart
testWidgets('Login to Vendor Details flow', (tester) async {
  // App launch کریں
  await tester.pumpWidget(MyApp());
  await tester.pumpAndSettle();
  
  // Login کریں
  await tester.enterText(
    find.byKey(Key('email')),
    'test@example.com',
  );
  await tester.enterText(
    find.byKey(Key('password')),
    'password123',
  );
  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();
  
  // Home screen پر ہونا چاہیے
  expect(find.text('Home'), findsOneWidget);
  
  // Vendor پر click کریں
  await tester.tap(find.text('Vendors'));
  await tester.pumpAndSettle();
  
  // Vendor list display ہونی چاہیے
  expect(find.byType(ListView), findsOneWidget);
});
```

## Project Structure سمجھیں

```
test/
├── helpers/              ← Helper functions
│   ├── test_helpers.dart
│   └── mock_data.dart
├── mocks/                ← Mock services
│   └── mock_services.dart
├── unit/                 ← یونٹ ٹیسٹس
│   ├── viewmodels/
│   └── utils/
└── widget/               ← ویجٹ ٹیسٹس
    └── vendor_details_view_test.dart

integration_test/         ← انٹیگریشن ٹیسٹس
└── app_test.dart
```

## Coverage Report دیکھیں

Test coverage یہ بتاتا ہے کہ آپ کے code کا کتنا حصہ test ہوا ہے۔

```bash
# Coverage generate کریں
flutter test --coverage

# HTML report بنائیں (optional)
genhtml coverage/lcov.info -o coverage/html

# Browser میں کھولیں
start coverage/html/index.html  # Windows
open coverage/html/index.html   # Mac
```

## مزید مدد (Resources)

- Test لکھنے میں مشکل؟ → `test/README.md` دیکھیں
- Example tests چاہیے؟ → `test/unit/` folder دیکھیں
- Widget testing؟ → `test/widget/` folder دیکھیں

## نتیجہ (Conclusion)

Testing سے:
- ✅ Code quality بہتر ہوتی ہے
- ✅ Bugs جلدی مل جاتے ہیں
- ✅ Refactoring آسان ہو جاتی ہے
- ✅ Team collaboration بہتر ہوتا ہے

**شروع کریں:**
```bash
# Dependencies install کریں
flutter pub get

# پہلا test چلائیں
flutter test test/unit/utils/string_utils_test.dart

# سب tests چلائیں
flutter test
```

---

**خوش Testing! 🧪✅**

کوئی سوال؟ Team سے رابطہ کریں!
