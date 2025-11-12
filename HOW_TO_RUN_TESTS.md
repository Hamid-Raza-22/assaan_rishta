# Testing Commands - Quick Reference

## 🚀 Quick Start

### پہلا قدم - Dependencies Install کریں
```bash
flutter pub get
```

### دوسرا قدم - Test چلائیں
```bash
# پہلا simple test
flutter test test/unit/utils/string_utils_test.dart

# سب tests
flutter test

# Coverage کے ساتھ
flutter test --coverage
```

## 📋 All Test Commands

### 1. Run All Tests (سب tests چلائیں)
```bash
flutter test
```

### 2. Run Unit Tests Only
```bash
flutter test test/unit/
```

### 3. Run Widget Tests Only
```bash
flutter test test/widget/
```

### 4. Run Integration Tests
```bash
flutter test integration_test/

# یا device پر
flutter drive --target=integration_test/app_test.dart
```

### 5. Run Specific Test File
```bash
flutter test test/unit/viewmodels/login_viewmodel_test.dart
```

### 6. Run Tests with Coverage
```bash
flutter test --coverage
```

### 7. Watch Mode (Auto-rerun on changes)
```bash
flutter test --watch
```

### 8. Run Tests with Detailed Output
```bash
flutter test --verbose
```

### 9. Run Specific Test by Name
```bash
flutter test --plain-name "Should validate email"
```

## 🎯 Testing Workflow

### Daily Development Workflow
```bash
# 1. Code change کریں
# 2. Related tests چلائیں
flutter test test/unit/

# 3. سب tests verify کریں
flutter test

# 4. Coverage check کریں
flutter test --coverage
```

### Before Committing Code
```bash
# 1. All tests pass کریں
flutter test

# 2. Code analysis
flutter analyze

# 3. Format check
dart format --set-exit-if-changed .

# 4. Coverage verify کریں
flutter test --coverage
```

## 📊 Understanding Test Output

### ✅ All Tests Pass
```
00:02 +15: All tests passed!
```
Matlab: سب 15 tests کامیابی سے pass ہوئے!

### ❌ Some Tests Failed
```
00:02 +10 -2: Some tests failed.
```
Matlab: 10 tests pass، 2 fail

### 🔄 Test Running
```
00:01 +5: loading test/unit/utils/string_utils_test.dart
```
Matlab: Tests abhi چل رہے ہیں

## 🔧 Troubleshooting Commands

### Problem: Tests not running
```bash
flutter clean
flutter pub get
flutter test
```

### Problem: Cache issues
```bash
flutter clean
rm -rf .dart_tool
flutter pub get
```

### Problem: Outdated packages
```bash
flutter pub upgrade
```

### Problem: Permission errors
```bash
# Run as administrator (Windows)
# Use sudo (Mac/Linux)
```

## 📁 Test File Organization

```
test/
├── unit/                    ← Business logic tests
│   ├── viewmodels/         ← ViewModel tests
│   └── utils/              ← Utility function tests
├── widget/                  ← UI component tests
│   ├── vendor_details_view_test.dart
│   └── custom_button_test.dart
└── helpers/                 ← Test helpers & mocks

integration_test/            ← Full app flow tests
└── app_test.dart
```

## 🎨 Test Types & When to Use

### Unit Tests (Fast, Isolated)
**کب استعمال کریں:**
- Function testing
- Validation logic
- Business calculations
- Data transformations

**Example:**
```bash
flutter test test/unit/
```

### Widget Tests (UI Components)
**کب استعمال کریں:**
- Button clicks
- Text display
- Form inputs
- UI interactions

**Example:**
```bash
flutter test test/widget/
```

### Integration Tests (Full Flows)
**کب استعمال کریں:**
- Login flows
- Navigation
- Complete user journeys
- API integrations

**Example:**
```bash
flutter test integration_test/
```

## 📈 Coverage Commands

### Generate Coverage Report
```bash
flutter test --coverage
```

### View Coverage (if lcov installed)
```bash
# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser (Windows)
start coverage/html/index.html

# Open in browser (Mac)
open coverage/html/index.html

# Open in browser (Linux)
xdg-open coverage/html/index.html
```

### Check Coverage Percentage
```bash
flutter test --coverage
# Then check coverage/lcov.info file
```

## 🚀 CI/CD Commands

### GitHub Actions (Automatic)
Tests automatically run on:
- Push to main/master/develop
- Pull requests

### Manual CI Commands
```bash
# What CI runs:
flutter pub get
flutter analyze
flutter test --coverage
dart format --set-exit-if-changed .
```

## 💡 Pro Tips

### 1. Run Tests in VS Code
- کھولیں Testing panel (flask icon)
- Click "Run All Tests"
- یا specific test پر right-click → Run

### 2. Debug Tests
```bash
# VS Code میں:
# - Test file کھولیں
# - Breakpoint لگائیں
# - Click "Debug" button
```

### 3. Filter Tests
```bash
# صرف "email" tests
flutter test --name=email

# صرف "validation" tests
flutter test --name=validation
```

### 4. Run Failed Tests Only
```bash
# پہلے run
flutter test

# صرف failed tests دوبارہ
flutter test --test-randomize-ordering-seed=123
```

## 📝 Common Scenarios

### Scenario 1: New Feature Added
```bash
# 1. Write test
# 2. Run specific test
flutter test test/unit/viewmodels/new_feature_test.dart

# 3. Verify all tests
flutter test
```

### Scenario 2: Bug Fix
```bash
# 1. Write failing test (reproduces bug)
# 2. Fix code
# 3. Run test to verify fix
flutter test test/unit/bug_fix_test.dart
```

### Scenario 3: Refactoring
```bash
# 1. Run all tests before
flutter test

# 2. Refactor code
# 3. Run tests after
flutter test

# 4. Verify coverage maintained
flutter test --coverage
```

## ⚡ Performance Tips

### Speed Up Tests
```bash
# Run in parallel (default)
flutter test --concurrency=4

# Run on VM only (faster than Chrome)
flutter test --platform=vm

# Skip slow tests
flutter test --exclude-tags=slow
```

### Cache Test Results
```bash
# Use --test-randomize-ordering-seed for reproducible results
flutter test --test-randomize-ordering-seed=12345
```

## 🎯 Next Steps

1. **Learn by doing:**
   ```bash
   flutter test test/unit/utils/string_utils_test.dart
   ```

2. **Write your first test:**
   - Copy example from `test/unit/`
   - Modify for your feature
   - Run it!

3. **Check documentation:**
   - `test/README.md` - Detailed guide
   - `TESTING_GUIDE_URDU.md` - اردو guide
   - `test/QUICKSTART.md` - Quick reference

## 📞 Need Help?

### Documentation
- English: `test/README.md`
- اردو: `TESTING_GUIDE_URDU.md`
- Quick: `test/QUICKSTART.md`

### Example Tests
Check these files for examples:
- `test/unit/utils/string_utils_test.dart`
- `test/widget/custom_button_test.dart`
- `integration_test/app_test.dart`

---

## ✅ Checklist Before Committing

```bash
☐ flutter test                    # All tests pass
☐ flutter analyze                 # No issues
☐ flutter test --coverage         # Check coverage
☐ dart format .                   # Code formatted
☐ Review changed files
☐ Update documentation if needed
```

---

**Start Testing Now! 🚀**

```bash
cd c:\flutterdev\projects\assaan_rishta
flutter pub get
flutter test
```
