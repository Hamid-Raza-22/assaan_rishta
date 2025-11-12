import 'package:flutter_test/flutter_test.dart';

/// Unit tests for utility functions
/// 
/// Ye tests helper functions aur utilities ko verify karte hain

void main() {
  group('String Utility Tests', () {
    test('Should capitalize first letter of string', () {
      expect(_capitalize('hello'), equals('Hello'));
      expect(_capitalize('world'), equals('World'));
      expect(_capitalize(''), equals(''));
    });

    test('Should slugify string correctly', () {
      expect(_slugify('Hello World'), equals('hello-world'));
      expect(_slugify('Test Vendor Name'), equals('test-vendor-name'));
      expect(_slugify('Special@#Characters'), equals('specialcharacters'));
    });

    test('Should format phone number', () {
      expect(_formatPhoneNumber('3001234567'), equals('+923001234567'));
      expect(_formatPhoneNumber('+923001234567'), equals('+923001234567'));
    });

    test('Should validate Pakistani phone number', () {
      expect(_isValidPakistaniPhone('+923001234567'), isTrue);
      expect(_isValidPakistaniPhone('03001234567'), isTrue);
      expect(_isValidPakistaniPhone('1234567890'), isTrue); // 10 digits is valid
    });

    test('Should truncate long strings', () {
      const longString = 'This is a very long string that needs to be truncated';
      expect(_truncate(longString, 20), equals('This is a very long  ...'));
      expect(_truncate('Short', 20), equals('Short'));
    });

    test('Should check if string is empty or null', () {
      expect(_isNullOrEmpty(null), isTrue);
      expect(_isNullOrEmpty(''), isTrue);
      expect(_isNullOrEmpty('   '), isTrue);
      expect(_isNullOrEmpty('hello'), isFalse);
    });
  });

  group('Date Utility Tests', () {
    test('Should format date correctly', () {
      final date = DateTime(2024, 1, 15);
      expect(_formatDate(date), equals('15 Jan 2024'));
    });

    test('Should calculate age from date of birth', () {
      final now = DateTime.now();
      final birthDate = DateTime(now.year - 25, now.month, now.day);
      expect(_calculateAge(birthDate), equals(25));
    });

    test('Should check if date is in past', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final futureDate = DateTime.now().add(const Duration(days: 1));
      
      expect(_isDateInPast(pastDate), isTrue);
      expect(_isDateInPast(futureDate), isFalse);
    });
  });
}

// Helper functions implementation
String _capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

String _slugify(String input) {
  return input
      .toLowerCase()
      .replaceAll(RegExp(r"[^a-z0-9\s-]"), '')
      .trim()
      .replaceAll(RegExp(r"\s+"), '-')
      .replaceAll(RegExp(r"-+"), '-');
}

String _formatPhoneNumber(String phone) {
  if (phone.startsWith('+92')) return phone;
  if (phone.startsWith('0')) {
    return '+92${phone.substring(1)}';
  }
  return '+92$phone';
}

bool _isValidPakistaniPhone(String phone) {
  final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
  // +923001234567 = 12 digits, 03001234567 = 11 digits
  return cleaned.length >= 10 && cleaned.length <= 12;
}

String _truncate(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength)} ...';
}

bool _isNullOrEmpty(String? text) {
  return text == null || text.trim().isEmpty;
}

String _formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
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

bool _isDateInPast(DateTime date) {
  return date.isBefore(DateTime.now());
}
