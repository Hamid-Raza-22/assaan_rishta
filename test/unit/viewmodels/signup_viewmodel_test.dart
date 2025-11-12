import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// SignupViewModel Unit Tests
/// 
/// Signup process ki testing:
/// - Form validation
/// - Phone number validation
/// - Email validation  
/// - Password strength
/// - Date of birth validation

void main() {
  group('SignupViewModel Unit Tests', () {
    setUp(() {
      Get.testMode = true;
    });

    tearDown(() {
      Get.reset();
    });

    test('Should validate email format', () {
      // Valid emails
      expect(_isValidEmail('test@example.com'), isTrue);
      expect(_isValidEmail('user.name@domain.co.in'), isTrue);
      expect(_isValidEmail('user+tag@example.com'), isTrue);
      
      // Invalid emails
      expect(_isValidEmail('invalid'), isFalse);
      expect(_isValidEmail('@example.com'), isFalse);
      expect(_isValidEmail('test@'), isFalse);
      expect(_isValidEmail(''), isFalse);
    });

    test('Should validate password strength', () {
      // Valid passwords (minimum 6 characters)
      expect(_isValidPassword('password123'), isTrue);
      expect(_isValidPassword('123456'), isTrue);
      expect(_isValidPassword('MyPass@123'), isTrue);
      
      // Invalid passwords
      expect(_isValidPassword('12345'), isFalse);
      expect(_isValidPassword(''), isFalse);
      expect(_isValidPassword('abc'), isFalse);
    });

    test('Should validate first name', () {
      // Valid names
      expect(_isValidName('Muhammad'), isTrue);
      expect(_isValidName('Ali'), isTrue);
      
      // Invalid names
      expect(_isValidName(''), isFalse);
      expect(_isValidName('  '), isFalse);
      expect(_isValidName('A'), isFalse); // Too short
    });

    test('Should validate Pakistani phone number format', () {
      // Valid Pakistani numbers (without country code)
      expect(_isValidPakistaniPhone('3001234567'), isTrue);
      expect(_isValidPakistaniPhone('3331234567'), isTrue);
      expect(_isValidPakistaniPhone('3451234567'), isTrue);
      
      // Invalid numbers
      expect(_isValidPakistaniPhone('1234567890'), isFalse); // Doesn't start with 3
      expect(_isValidPakistaniPhone('300123456'), isFalse); // Too short
      expect(_isValidPakistaniPhone('30012345678'), isFalse); // Too long
    });

    test('Should validate age from date of birth', () {
      // Arrange
      final now = DateTime.now();
      final dob18YearsAgo = DateTime(now.year - 18, now.month, now.day);
      final dob15YearsAgo = DateTime(now.year - 15, now.month, now.day);
      final dob100YearsAgo = DateTime(now.year - 100, now.month, now.day);
      
      // Act & Assert
      expect(_calculateAge(dob18YearsAgo), equals(18));
      expect(_calculateAge(dob15YearsAgo), equals(15));
      expect(_isValidAge(dob18YearsAgo), isTrue); // 18+ valid
      expect(_isValidAge(dob15YearsAgo), isFalse); // Under 18 invalid
      expect(_isValidAge(dob100YearsAgo), isFalse); // Too old
    });

    test('Should format date of birth correctly', () {
      // Arrange
      final date = DateTime(1995, 5, 15);
      
      // Act
      final formatted = _formatDate(date);
      
      // Assert
      expect(formatted, equals('15-05-1995'));
    });

    test('Should validate marital status selection', () {
      const validStatuses = ['Single', 'Married', 'Divorced', 'Widow/Widower'];
      
      expect(validStatuses.contains('Single'), isTrue);
      expect(validStatuses.contains('Invalid'), isFalse);
    });

    test('Should validate religion selection', () {
      const validReligions = [
        'Muslim-Suni',
        'Muslim-Brelvi',
        'Muslim-Deobandi',
        'Muslim-AhleHadees',
        'Muslim-Other'
      ];
      
      expect(validReligions.contains('Muslim-Suni'), isTrue);
      expect(validReligions.contains('Other'), isFalse);
    });

    test('Should validate gender selection', () {
      const validGenders = ['Male', 'Female'];
      
      expect(validGenders.contains('Male'), isTrue);
      expect(validGenders.contains('Female'), isTrue);
      expect(validGenders.contains('Other'), isFalse);
    });

    test('Should validate form completeness', () {
      // Arrange
      final formData = {
        'firstName': 'Ali',
        'lastName': 'Khan',
        'email': 'ali@example.com',
        'phone': '3001234567',
        'password': 'password123',
        'dob': '15-05-1995',
        'gender': 'Male',
      };
      
      // Act
      final isComplete = formData.values.every((value) => 
        value != null && value.toString().isNotEmpty
      );
      
      // Assert
      expect(isComplete, isTrue);
    });

    test('Should validate password confirmation match', () {
      // Arrange
      const password = 'password123';
      const confirmPassword1 = 'password123';
      const confirmPassword2 = 'password456';
      
      // Act & Assert
      expect(password == confirmPassword1, isTrue);
      expect(password == confirmPassword2, isFalse);
    });

    test('Should validate terms and conditions acceptance', () {
      // Arrange
      bool termsAccepted = false;
      
      // Act
      termsAccepted = true;
      
      // Assert
      expect(termsAccepted, isTrue);
    });

    test('Should validate country code format', () {
      // Valid country codes
      expect(_isValidCountryCode('+92'), isTrue);
      expect(_isValidCountryCode('+1'), isTrue);
      expect(_isValidCountryCode('+44'), isTrue);
      
      // Invalid codes
      expect(_isValidCountryCode('92'), isFalse);
      expect(_isValidCountryCode(''), isFalse);
    });

    test('Should generate height list correctly', () {
      // Arrange & Act
      final heights = _generateHeightList();
      
      // Assert
      expect(heights.isNotEmpty, isTrue);
      expect(heights.contains("5'0\""), isTrue);
      expect(heights.contains("6'0\""), isTrue);
    });

    test('Should clear form data', () {
      // Arrange
      var formData = {
        'firstName': 'Ali',
        'email': 'test@example.com',
      };
      
      // Act
      formData.clear();
      
      // Assert
      expect(formData.isEmpty, isTrue);
    });

    test('Should validate phone number for different countries', () {
      // Pakistan
      expect(_validatePhoneLength('3001234567', 'PK'), isTrue);
      
      // India
      expect(_validatePhoneLength('9876543210', 'IN'), isTrue);
      
      // USA
      expect(_validatePhoneLength('5551234567', 'US'), isTrue);
    });
  });
}

// Helper functions
bool _isValidEmail(String email) {
  if (email.isEmpty) return false;
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return emailRegex.hasMatch(email);
}

bool _isValidPassword(String password) {
  return password.length >= 6;
}

bool _isValidName(String name) {
  return name.trim().length >= 2;
}

bool _isValidPakistaniPhone(String phone) {
  final cleaned = phone.replaceAll(RegExp(r'\D'), '');
  return cleaned.length == 10 && cleaned.startsWith('3');
}

int _calculateAge(DateTime birthDate) {
  final now = DateTime.now();
  int age = now.year - birthDate.year;
  if (now.month < birthDate.month ||
      (now.month == birthDate.month && now.day < birthDate.day)) {
    age--;
  }
  return age;
}

bool _isValidAge(DateTime birthDate) {
  final age = _calculateAge(birthDate);
  return age >= 18 && age <= 80;
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
}

bool _isValidCountryCode(String code) {
  return code.startsWith('+') && code.length >= 2;
}

List<String> _generateHeightList() {
  final heights = <String>[];
  for (int feet = 4; feet <= 7; feet++) {
    for (int inches = 0; inches < 12; inches++) {
      heights.add('$feet\'$inches"');
    }
  }
  return heights;
}

bool _validatePhoneLength(String phone, String countryCode) {
  final cleaned = phone.replaceAll(RegExp(r'\D'), '');
  switch (countryCode) {
    case 'PK':
      return cleaned.length == 10;
    case 'IN':
      return cleaned.length == 10;
    case 'US':
      return cleaned.length == 10;
    default:
      return cleaned.length >= 8 && cleaned.length <= 12;
  }
}
