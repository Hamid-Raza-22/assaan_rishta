import 'package:flutter_test/flutter_test.dart';

// Unit Tests
import 'unit/viewmodels/login_viewmodel_test.dart' as login_vm_test;
import 'unit/viewmodels/home_viewmodel_test.dart' as home_vm_test;
import 'unit/viewmodels/profile_viewmodel_test.dart' as profile_vm_test;
import 'unit/viewmodels/signup_viewmodel_test.dart' as signup_vm_test;
import 'unit/viewmodels/filter_viewmodel_test.dart' as filter_vm_test;
import 'unit/utils/string_utils_test.dart' as string_utils_test;

// Widget Tests
import 'widget/vendor_details_view_test.dart' as vendor_details_test;
import 'widget/custom_button_test.dart' as custom_button_test;
import 'widget/home_view_test.dart' as home_view_test;
import 'widget/login_view_test.dart' as login_view_test;
import 'widget/filter_view_test.dart' as filter_view_test;
import 'widget/profile_view_test.dart' as profile_view_test;

/// Test Suite Runner
/// 
/// Ye file sab tests ko ek sath chalane ke liye hai
/// 
/// Run karne ka tareeqa:
/// flutter test test/test_suite.dart

void main() {
  group('🧪 Assaan Rishta Complete Test Suite', () {
    
    group('📦 Unit Tests - ViewModels', () {
      login_vm_test.main();
      home_vm_test.main();
      profile_vm_test.main();
      signup_vm_test.main();
      filter_vm_test.main();
    });

    group('🔧 Unit Tests - Utilities', () {
      string_utils_test.main();
    });

    group('🎨 Widget Tests - Views', () {
      vendor_details_test.main();
      custom_button_test.main();
      home_view_test.main();
      login_view_test.main();
      filter_view_test.main();
      profile_view_test.main();
    });

    // Integration tests should be run separately
    // flutter test integration_test/
  });
}
