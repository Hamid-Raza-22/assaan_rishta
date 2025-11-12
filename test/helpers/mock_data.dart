/// Mock data for testing purposes

class MockData {
  // Mock User Data
  static Map<String, dynamic> get mockUser => {
        'uid': 'test_user_123',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'phoneNumber': '+923001234567',
      };

  // Mock Vendor Data
  static Map<String, dynamic> get mockVendor => {
        'venderID': 'vendor_123',
        'venderBusinessName': 'Test Vendor Business',
        'vendorCategoryName': 'Wedding Venue',
        'venderEmail': 'vendor@example.com',
        'venderPhone': '+923001234567',
        'logo': 'https://example.com/logo.png',
        'aboutCompany': 'This is a test vendor company',
        'venderAddress': '123 Test Street, Test City',
        'vendorCityName': 'Karachi',
      };

  // Mock Service Data
  static List<Map<String, dynamic>> get mockServices => [
        {
          'servicesName': 'Photography',
          'serviceId': 'service_1',
        },
        {
          'servicesName': 'Catering',
          'serviceId': 'service_2',
        },
        {
          'servicesName': 'Decoration',
          'serviceId': 'service_3',
        },
      ];

  // Mock Package Data
  static List<Map<String, dynamic>> get mockPackages => [
        {
          'packageName': 'Basic Package',
          'packageMinPrice': '50000',
          'packageMaxPrice': '100000',
          'packagePriceType': 'Per Event',
          'packageTaxPrice': 'Tax Inclusive',
          'packageDiscription': 'Basic package includes photography and decoration',
        },
        {
          'packageName': 'Premium Package',
          'packageMinPrice': '150000',
          'packageMaxPrice': '250000',
          'packagePriceType': 'Per Event',
          'packageTaxPrice': 'Tax Exclusive',
          'packageDiscription': 'Premium package includes all services',
        },
      ];

  // Mock Questions Data
  static List<Map<String, dynamic>> get mockQuestions => [
        {
          'qusetion1': 'What is your booking policy?',
          'answer': 'We require 50% advance payment to confirm booking',
        },
        {
          'qusetion1': 'Do you provide outdoor services?',
          'answer': 'Yes, we provide both indoor and outdoor services',
        },
      ];

  // Mock Album Data
  static List<Map<String, dynamic>> get mockAlbums => [
        {
          'imagesName': 'https://example.com/image1.jpg',
          'albumId': 'album_1',
        },
        {
          'imagesName': 'https://example.com/image2.jpg',
          'albumId': 'album_2',
        },
      ];

  // Mock Video Data
  static List<Map<String, dynamic>> get mockVideos => [
        {
          'videoName': 'https://example.com/video1.mp4',
          'videoId': 'video_1',
        },
        {
          'videoName': 'https://example.com/video2.mp4',
          'videoId': 'video_2',
        },
      ];

  // Mock Chat Data
  static Map<String, dynamic> get mockChatMessage => {
        'messageId': 'msg_123',
        'senderId': 'user_123',
        'receiverId': 'user_456',
        'message': 'Hello, this is a test message',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'isRead': false,
      };

  // Mock Profile Data
  static Map<String, dynamic> get mockProfile => {
        'userId': 'user_123',
        'name': 'Test User',
        'email': 'test@example.com',
        'phone': '+923001234567',
        'city': 'Karachi',
        'age': 25,
        'gender': 'Male',
        'maritalStatus': 'Single',
      };
}
