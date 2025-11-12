# Test Commands Quick Reference

## Run All Tests
```bash
flutter test
```

## Run by Category
```bash
# Unit tests
flutter test test/unit/

# Widget tests  
flutter test test/widget/

# Integration tests
flutter test integration_test/
```

## Run Specific Tests
```bash
# ViewModels
flutter test test/unit/viewmodels/home_viewmodel_test.dart
flutter test test/unit/viewmodels/profile_viewmodel_test.dart
flutter test test/unit/viewmodels/signup_viewmodel_test.dart
flutter test test/unit/viewmodels/filter_viewmodel_test.dart

# Views
flutter test test/widget/home_view_test.dart
flutter test test/widget/login_view_test.dart
flutter test test/widget/profile_view_test.dart
```

## With Coverage
```bash
flutter test --coverage
```

## Test Suite
```bash
flutter test test/test_suite.dart
```

## Watch Mode
```bash
flutter test --watch
```
