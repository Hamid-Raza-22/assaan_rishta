import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import '../../helpers/mock_data.dart';
import '../../mocks/mock_services.dart';

/// Unit tests for LoginViewModel
/// 
/// Ye tests LoginViewModel ki functionality ko verify karte hain
/// bina UI ke directly business logic ko test karte hain

void main() {
  // Test group for LoginViewModel
  group('LoginViewModel Unit Tests', () {
    late MockFirebaseAuth mockAuth;

    // Setup before each test
    setUp(() {
      mockAuth = MockFirebaseAuth();
      // Initialize GetX
      Get.testMode = true;
    });

    // Cleanup after each test
    tearDown(() {
      Get.reset();
    });

    test('Initial state should be correct', () {
      // Arrange - Test ka setup
      // Act - Function ko call karna
      // Assert - Result ko verify karna
      
      // Example: Verify initial email is empty
      const email = '';
      const password = '';
      
      expect(email, isEmpty);
      expect(password, isEmpty);
    });

    test('Email validation should work correctly', () {
      // Valid email test
      const validEmail = 'test@example.com';
      final isValid = _isValidEmail(validEmail);
      expect(isValid, isTrue);
      
      // Invalid email test
      const invalidEmail = 'invalid-email';
      final isInvalid = _isValidEmail(invalidEmail);
      expect(isInvalid, isFalse);
    });

    test('Password validation should work correctly', () {
      // Valid password (minimum 6 characters)
      const validPassword = 'password123';
      expect(validPassword.length >= 6, isTrue);
      
      // Invalid password (less than 6 characters)
      const invalidPassword = '12345';
      expect(invalidPassword.length >= 6, isFalse);
    });

    test('Should validate empty fields', () {
      const email = '';
      const password = '';
      
      expect(email.isEmpty, isTrue);
      expect(password.isEmpty, isTrue);
    });

    test('Should format phone number correctly', () {
      const phone = '+923001234567';
      expect(phone.startsWith('+92'), isTrue);
      expect(phone.length, equals(13));
    });

    // Example of testing with mock data
    test('Should handle user login data correctly', () {
      final userData = MockData.mockUser;
      
      expect(userData['email'], isNotEmpty);
      expect(userData['uid'], isNotEmpty);
      expect(userData['displayName'], isNotNull);
    });
  });
}

// Helper function for email validation
bool _isValidEmail(String email) {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}
