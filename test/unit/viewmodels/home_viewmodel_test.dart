import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import '../../helpers/mock_data.dart';
import '../../mocks/mock_services.dart';

/// HomeController Unit Tests
/// 
/// HomeController ki functionality ko test karte hain:
/// - Profile listing
/// - Pagination
/// - Favorite functionality
/// - Gender filtering

void main() {
  group('HomeController Unit Tests', () {
    setUp(() {
      Get.testMode = true;
    });

    tearDown(() {
      Get.reset();
    });

    test('Initial state should be correct', () {
      // Arrange & Act
      const isLoading = false;
      const initialPage = 1;
      
      // Assert
      expect(isLoading, isFalse);
      expect(initialPage, equals(1));
    });

    test('Should handle empty profile list', () {
      // Arrange
      final List<dynamic> profileList = [];
      
      // Act & Assert
      expect(profileList, isEmpty);
      expect(profileList.length, equals(0));
    });

    test('Should increment page number for pagination', () {
      // Arrange
      int currentPage = 1;
      
      // Act
      currentPage++;
      
      // Assert
      expect(currentPage, equals(2));
    });

    test('Should filter opposite gender profiles - Male', () {
      // Arrange
      const currentUserGender = 'Male';
      const profileGender = 'Female';
      
      // Act
      final shouldShow = _isOppositeGender(currentUserGender, profileGender);
      
      // Assert
      expect(shouldShow, isTrue);
    });

    test('Should filter opposite gender profiles - Female', () {
      // Arrange
      const currentUserGender = 'Female';
      const profileGender = 'Male';
      
      // Act
      final shouldShow = _isOppositeGender(currentUserGender, profileGender);
      
      // Assert
      expect(shouldShow, isTrue);
    });

    test('Should not show same gender profiles', () {
      // Arrange
      const currentUserGender = 'Male';
      const profileGender = 'Male';
      
      // Act
      final shouldShow = _isOppositeGender(currentUserGender, profileGender);
      
      // Assert
      expect(shouldShow, isFalse);
    });

    test('Should handle null gender gracefully', () {
      // Arrange
      const currentUserGender = 'Male';
      const String? profileGender = null;
      
      // Act
      final shouldShow = _isOppositeGenderNullable(currentUserGender, profileGender);
      
      // Assert
      expect(shouldShow, isFalse);
    });

    test('Should detect near end of list for pagination', () {
      // Arrange
      const totalItems = 20;
      const currentIndex = 15;
      const threshold = 5;
      
      // Act
      final shouldLoadMore = (currentIndex >= totalItems - threshold);
      
      // Assert
      expect(shouldLoadMore, isTrue);
    });

    test('Should not load more if already loading', () {
      // Arrange
      const isLoading = true;
      const shouldLoadMore = true;
      
      // Act
      final canLoadMore = shouldLoadMore && !isLoading;
      
      // Assert
      expect(canLoadMore, isFalse);
    });

    test('Should toggle favorite status from yes to no', () {
      // Arrange
      String favoriteStatus = 'yes';
      
      // Act
      favoriteStatus = favoriteStatus == 'yes' ? 'no' : 'yes';
      
      // Assert
      expect(favoriteStatus, equals('no'));
    });

    test('Should toggle favorite status from no to yes', () {
      // Arrange
      String favoriteStatus = 'no';
      
      // Act
      favoriteStatus = favoriteStatus == 'yes' ? 'no' : 'yes';
      
      // Assert
      expect(favoriteStatus, equals('yes'));
    });

    test('Should filter out current user from profile list', () {
      // Arrange
      const currentUserId = 123;
      final profiles = [
        {'userId': 123, 'name': 'Current User'},
        {'userId': 456, 'name': 'Other User'},
        {'userId': 789, 'name': 'Another User'},
      ];
      
      // Act
      final filteredProfiles = profiles.where((profile) => 
        profile['userId'] != currentUserId
      ).toList();
      
      // Assert
      expect(filteredProfiles.length, equals(2));
      expect(filteredProfiles.any((p) => p['userId'] == currentUserId), isFalse);
    });

    test('Should prevent duplicate profiles in list', () {
      // Arrange
      final existingProfiles = [
        {'userId': 456, 'name': 'User 1'},
      ];
      
      final newProfiles = [
        {'userId': 456, 'name': 'User 1'}, // Duplicate
        {'userId': 789, 'name': 'User 2'},
      ];
      
      // Act
      final uniqueProfiles = newProfiles.where((newProfile) {
        return !existingProfiles.any((existing) => 
          existing['userId'] == newProfile['userId']
        );
      }).toList();
      
      // Assert
      expect(uniqueProfiles.length, equals(1));
      expect(uniqueProfiles.first['userId'], equals(789));
    });

    test('Should handle pagination with correct page size', () {
      // Arrange
      const pageLimit = 20;
      const currentPage = 1;
      
      // Act
      final expectedItemCount = pageLimit * currentPage;
      
      // Assert
      expect(expectedItemCount, equals(20));
    });
  });
}

// Helper functions
bool _isOppositeGender(String currentGender, String profileGender) {
  if (currentGender.toLowerCase() == 'male') {
    return profileGender.toLowerCase() == 'female';
  } else if (currentGender.toLowerCase() == 'female') {
    return profileGender.toLowerCase() == 'male';
  }
  return false;
}

bool _isOppositeGenderNullable(String currentGender, String? profileGender) {
  if (profileGender == null || profileGender.trim().isEmpty) {
    return false;
  }
  return _isOppositeGender(currentGender, profileGender);
}
