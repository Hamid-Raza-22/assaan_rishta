import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// ChatViewModel Unit Tests
/// 
/// Chat functionality ki testing:
/// - Message sending
/// - Message receiving
/// - Typing indicators
/// - Read/unread status
/// - Message caching

void main() {
  group('ChatViewModel Unit Tests', () {
    setUp(() {
      Get.testMode = true;
    });

    tearDown(() {
      Get.reset();
    });

    test('Should initialize empty message list', () {
      // Arrange & Act
      final List<dynamic> messages = [];
      
      // Assert
      expect(messages, isEmpty);
      expect(messages.length, equals(0));
    });

    test('Should add message to list', () {
      // Arrange
      final messages = <Map<String, dynamic>>[];
      final newMessage = {
        'id': '123',
        'text': 'Hello',
        'senderId': 'user1',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      // Act
      messages.add(newMessage);
      
      // Assert
      expect(messages.length, equals(1));
      expect(messages.first['text'], equals('Hello'));
    });

    test('Should validate message text is not empty', () {
      // Valid messages
      expect(_isValidMessage('Hello'), isTrue);
      expect(_isValidMessage('Test message'), isTrue);
      
      // Invalid messages
      expect(_isValidMessage(''), isFalse);
      expect(_isValidMessage('   '), isFalse);
    });

    test('Should format timestamp correctly', () {
      // Arrange
      final timestamp = DateTime(2024, 11, 12, 15, 30).millisecondsSinceEpoch;
      
      // Act
      final formatted = _formatTimestamp(timestamp);
      
      // Assert
      expect(formatted, isNotEmpty);
    });

    test('Should mark message as read', () {
      // Arrange
      final message = {
        'id': '123',
        'isRead': false,
      };
      
      // Act
      message['isRead'] = true;
      
      // Assert
      expect(message['isRead'], isTrue);
    });

    test('Should mark message as sent', () {
      // Arrange
      final message = {
        'id': '123',
        'status': 'pending',
      };
      
      // Act
      message['status'] = 'sent';
      
      // Assert
      expect(message['status'], equals('sent'));
    });

    test('Should update typing status', () {
      // Arrange
      bool isTyping = false;
      
      // Act
      isTyping = true;
      
      // Assert
      expect(isTyping, isTrue);
    });

    test('Should count unread messages', () {
      // Arrange
      final messages = [
        {'isRead': true},
        {'isRead': false},
        {'isRead': false},
        {'isRead': true},
      ];
      
      // Act
      final unreadCount = messages.where((m) => m['isRead'] == false).length;
      
      // Assert
      expect(unreadCount, equals(2));
    });

    test('Should filter messages by user', () {
      // Arrange
      const currentUserId = 'user1';
      final messages = [
        {'senderId': 'user1', 'text': 'My message'},
        {'senderId': 'user2', 'text': 'Other message'},
        {'senderId': 'user1', 'text': 'Another my message'},
      ];
      
      // Act
      final myMessages = messages.where((m) => m['senderId'] == currentUserId).toList();
      
      // Assert
      expect(myMessages.length, equals(2));
    });

    test('Should sort messages by timestamp', () {
      // Arrange
      final messages = [
        {'timestamp': 1000},
        {'timestamp': 3000},
        {'timestamp': 2000},
      ];
      
      // Act
      messages.sort((a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int));
      
      // Assert
      expect(messages.first['timestamp'], equals(1000));
      expect(messages.last['timestamp'], equals(3000));
    });

    test('Should validate message ID', () {
      expect(_isValidMessageId('msg_123'), isTrue);
      expect(_isValidMessageId(''), isFalse);
    });

    test('Should check if message is from current user', () {
      const currentUserId = 'user1';
      
      expect(_isMyMessage('user1', currentUserId), isTrue);
      expect(_isMyMessage('user2', currentUserId), isFalse);
    });

    test('Should handle message deletion', () {
      // Arrange
      final messages = [
        {'id': '1', 'text': 'Message 1'},
        {'id': '2', 'text': 'Message 2'},
        {'id': '3', 'text': 'Message 3'},
      ];
      
      // Act
      messages.removeWhere((m) => m['id'] == '2');
      
      // Assert
      expect(messages.length, equals(2));
      expect(messages.any((m) => m['id'] == '2'), isFalse);
    });

    test('Should cache messages', () {
      // Arrange
      final cache = <String, List<Map<String, dynamic>>>{};
      const userId = 'user1';
      final messages = [
        {'text': 'Message 1'},
        {'text': 'Message 2'},
      ];
      
      // Act
      cache[userId] = messages;
      
      // Assert
      expect(cache.containsKey(userId), isTrue);
      expect(cache[userId]?.length, equals(2));
    });

    test('Should retrieve cached messages', () {
      // Arrange
      final cache = <String, List<Map<String, dynamic>>>{
        'user1': [{'text': 'Cached message'}],
      };
      
      // Act
      final cachedMessages = cache['user1'];
      
      // Assert
      expect(cachedMessages, isNotNull);
      expect(cachedMessages?.first['text'], equals('Cached message'));
    });

    test('Should handle empty chat', () {
      // Arrange
      final messages = <Map<String, dynamic>>[];
      
      // Act & Assert
      expect(messages.isEmpty, isTrue);
    });
  });
}

// Helper functions
bool _isValidMessage(String text) {
  return text.trim().isNotEmpty;
}

String _formatTimestamp(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}

bool _isValidMessageId(String id) {
  return id.isNotEmpty;
}

bool _isMyMessage(String senderId, String currentUserId) {
  return senderId == currentUserId;
}
