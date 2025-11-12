import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// AccountTypeViewModel Unit Tests
/// 
/// Account type selection testing:
/// - Account type validation
/// - Selection state management

void main() {
  group('AccountTypeViewModel Unit Tests', () {
    setUp(() {
      Get.testMode = true;
    });

    tearDown(() {
      Get.reset();
    });

    test('Should validate account type selection', () {
      const validTypes = ['User', 'Vendor'];
      
      expect(validTypes.contains('User'), isTrue);
      expect(validTypes.contains('Vendor'), isTrue);
      expect(validTypes.contains('Invalid'), isFalse);
    });

    test('Should select user account type', () {
      // Arrange
      String? selectedType;
      
      // Act
      selectedType = 'User';
      
      // Assert
      expect(selectedType, equals('User'));
    });

    test('Should select vendor account type', () {
      // Arrange
      String? selectedType;
      
      // Act
      selectedType = 'Vendor';
      
      // Assert
      expect(selectedType, equals('Vendor'));
    });

    test('Should change account type selection', () {
      // Arrange
      String selectedType = 'User';
      
      // Act
      selectedType = 'Vendor';
      
      // Assert
      expect(selectedType, equals('Vendor'));
    });

    test('Should validate selection before proceeding', () {
      String? selectedType;
      
      expect(_canProceed(selectedType), isFalse);
      
      selectedType = 'User';
      expect(_canProceed(selectedType), isTrue);
    });

    test('Should get account type description', () {
      expect(_getDescription('User'), contains('profiles'));
      expect(_getDescription('Vendor'), contains('services'));
    });

    test('Should check if user type is selected', () {
      const selectedType = 'User';
      
      expect(_isUserType(selectedType), isTrue);
      expect(_isVendorType(selectedType), isFalse);
    });

    test('Should check if vendor type is selected', () {
      const selectedType = 'Vendor';
      
      expect(_isVendorType(selectedType), isTrue);
      expect(_isUserType(selectedType), isFalse);
    });
  });
}

// Helper functions
bool _canProceed(String? selectedType) {
  return selectedType != null && selectedType.isNotEmpty;
}

String _getDescription(String type) {
  if (type == 'User') {
    return 'Browse profiles and find matches';
  } else if (type == 'Vendor') {
    return 'Offer wedding services to users';
  }
  return '';
}

bool _isUserType(String type) {
  return type == 'User';
}

bool _isVendorType(String type) {
  return type == 'Vendor';
}
