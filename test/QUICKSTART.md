# Testing Quick Start Guide ⚡

Assaan Rishta app ki testing شروع کرنے کے لیے یہ quick guide follow کریں۔

## 🚀 Quick Setup (5 minutes)

### Step 1: Dependencies Install کریں
```bash
cd c:\flutterdev\projects\assaan_rishta
flutter pub get
```

### Step 2: پہلا Test Run کریں
```bash
flutter test test/unit/utils/string_utils_test.dart
```

✅ اگر سب tests pass ہوں تو آپ ready ہیں!

## 📝 Quick Commands

### سب tests چلانا
```bash
flutter test
```

### Specific folder tests
```bash
# Unit tests
flutter test test/unit/

# Widget tests
flutter test test/widget/

# Integration tests
flutter test integration_test/
```

### ایک file کا test
```bash
flutter test test/unit/viewmodels/login_viewmodel_test.dart
```

### Coverage check کرنا
```bash
flutter test --coverage
```

## 📁 Project Structure

```
assaan_rishta/
├── test/
│   ├── helpers/           ← Test helpers & mock data
│   ├── mocks/             ← Mock services (Firebase, etc)
│   ├── unit/              ← یونٹ ٹیسٹس
│   │   ├── viewmodels/
│   │   └── utils/
│   └── widget/            ← ویجٹ ٹیسٹس
├── integration_test/      ← انٹیگریشن ٹیسٹس
└── test_driver/           ← Integration test driver
```

## ✍️ اپنا Test لکھیں

### Template: Unit Test
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Description', () {
    test('Should do something', () {
      // Arrange
      final input = 'test';
      
      // Act
      final result = process(input);
      
      // Assert
      expect(result, equals('expected'));
    });
  });
}
```

### Template: Widget Test
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Widget test description', (tester) async {
    // Arrange
    await tester.pumpWidget(
      MaterialApp(home: MyWidget()),
    );
    
    // Act
    await tester.tap(find.text('Button'));
    await tester.pump();
    
    // Assert
    expect(find.text('Result'), findsOneWidget);
  });
}
```

## 🎯 Common Test Scenarios

### 1. Login Validation Test
```dart
test('Email validation', () {
  expect(isValidEmail('test@example.com'), isTrue);
  expect(isValidEmail('invalid'), isFalse);
});
```

### 2. Button Click Test
```dart
testWidgets('Button click', (tester) async {
  bool clicked = false;
  
  await tester.pumpWidget(
    MaterialApp(
      home: ElevatedButton(
        onPressed: () => clicked = true,
        child: Text('Click'),
      ),
    ),
  );
  
  await tester.tap(find.text('Click'));
  expect(clicked, isTrue);
});
```

### 3. Text Display Test
```dart
testWidgets('Text display', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Text('Hello World'),
    ),
  );
  
  expect(find.text('Hello World'), findsOneWidget);
});
```

## 🐛 Troubleshooting

### ❌ "Package not found"
```bash
flutter pub get
flutter clean
flutter pub get
```

### ❌ GetX tests failing
```dart
setUp(() {
  Get.testMode = true;
});

tearDown(() {
  Get.reset();
});
```

### ❌ Widget not found
```dart
await tester.pumpAndSettle();  // Add this
```

### ❌ Network image error
```dart
mockNetworkImagesFor(() async {
  await tester.pumpWidget(MyWidget());
});
```

## 📊 Test Results کی تفسیر

```bash
✓ Should validate email correctly     # ✅ Pass
✓ Should handle empty input           # ✅ Pass
✗ Should format phone number          # ❌ Fail
  Expected: +923001234567
  Actual: 03001234567
```

## 🎓 مزید سیکھیں

- **تفصیلی گائیڈ:** `test/README.md`
- **اردو گائیڈ:** `TESTING_GUIDE_URDU.md`
- **Example Tests:** `test/unit/` اور `test/widget/` folders

## ⚡ Daily Testing Workflow

```bash
# 1. Code لکھیں
# 2. Test لکھیں یا موجودہ test چلائیں
flutter test

# 3. اگر fail ہو تو fix کریں
# 4. دوبارہ test چلائیں
flutter test --coverage

# 5. Coverage check کریں
```

## 📈 Coverage Targets

- **Good:** 60%+ coverage
- **Great:** 80%+ coverage
- **Excellent:** 90%+ coverage

Check کریں:
```bash
flutter test --coverage
# پھر coverage/lcov.info file دیکھیں
```

## 🚦 Next Steps

1. ✅ `flutter pub get` چلائیں
2. ✅ `flutter test` چلائیں
3. ✅ اپنا پہلا test لکھیں
4. ✅ Coverage report دیکھیں

## 💡 Pro Tips

- 🔄 **Test-Driven Development:** پہلے test لکھیں، پھر code
- 🧪 **Mock External Services:** API calls, Firebase ko mock کریں
- 📝 **Clear Test Names:** Test کا نام واضح اور descriptive رکھیں
- 🔍 **Test Edge Cases:** Normal cases کے ساتھ edge cases بھی test کریں

## 📞 مدد چاہیے?

- Documentation: `test/README.md`
- Examples: `test/` folder میں دیکھیں
- Team: اپنی team سے پوچھیں

---

**Happy Testing! 🧪✨**

شروع کرنے کے لیے ابھی چلائیں:
```bash
flutter test test/unit/utils/string_utils_test.dart
```
