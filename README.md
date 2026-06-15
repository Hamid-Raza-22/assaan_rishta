# assaan_rishta

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



📦 Firestore Root

├── users (Collection) // Stores user profile data
│   ├── {userId} (Document) // Unique user document (e.g., UID from Firebase Auth)
│   │   ├── name: "Hamid Raza" // Full name of the user
│   │   ├── email: "hamid@example.com" // Email address (if used for login or contact)
│   │   ├── phoneNumber: "+923001234567" // User's phone number
│   │   ├── profilePicture: "url" // Profile image URL
│   │   ├── about: "Available" // User's custom status
│   │   ├── isOnline: true // Realtime online status
│   │   ├── lastSeen: Timestamp // Timestamp of the last time the user was online
│   │   ├── pushToken: "device_push_token_for_notifications" // Used for sending FCM push notifications
│   │   ├── settings: // User-specific chat/privacy settings
│   │   │   ├── readReceipts: true // Show/hide read receipts
│   │   │   ├── lastSeenVisible: true // Show/hide last seen to others
│   │   │   ├── typingVisible: true // Show/hide typing indicator
│   │   └── ... (other metadata) // e.g., language, theme, etc.

├── chats (Collection) // Stores all chat threads (1-on-1 or groups)
│   ├── {chatId} (Document) // Unique chat ID (e.g., user1_user2 or UUID)
│   │   ├── members: [userId1, userId2] // IDs of users in the chat
│   │   ├── isGroup: false // true for group chat, false for 1-to-1
│   │   ├── createdAt: Timestamp // When the chat was created
│   │   ├── createdBy: userId1 // Who created this chat
│   │   ├── lastMessage: "Hi there" // Content of the last message
│   │   ├── lastMessageTime: Timestamp // When the last message was sent
│   │   ├── unreadCount: // Number of unread messages per user
│   │   │   ├── userId1: 0
│   │   │   ├── userId2: 1
│   │   ├── typing: // Typing status of each user (for UI indicator)
│   │   │   ├── userId1: false
│   │   │   ├── userId2: true
│   │   ├── pinnedBy: [userId1] // Users who pinned this chat
│   │   ├── archivedBy: [userId2] // Users who archived this chat
│   │   ├── blockedBy: null /[userId, .....] // Shows if the chat is blocked by someone
│   │   ├── chatBackgrounds: // Individual chat background for each user
│   │   │   ├── userId1: "url_or_color_code"
│   │   │   ├── userId2: "url_or_color_code"
│   │   └── ...

│   │   └── messages (Subcollection) // Stores all messages for this chat
│   │       ├── {messageId} (Document) // Unique ID per message
│   │       │   ├── senderId: userId1 // Who sent the message
│   │       │   ├── receiverId: userId2 // Who received the message
│   │       │   ├── content: "Hello!" // The actual message text
│   │       │   ├── timestamp: Timestamp // When the message was sent
│   │       │   ├── messageType: "text" / "image" / "video" / "file" / "audio" / "location" / "contact"
│   │       │   ├── mediaUrl: "url" // Used for media messages
│   │       │   ├── seenBy: [userId2] // List of users who have seen this message
│   │       │   ├── deletedFor: [userId1] // Users who deleted this message for themselves
│   │       │   ├── repliedTo: messageId // ID of the original message if this is a reply
│   │       │   ├── forwarded: true / false // Indicates if message was forwarded
│   │       │   ├── reactions: // Emoji reactions to messages
│   │       │   │   ├── userId2: "❤️"
│   │       │   └── ...
│
├── userChats (Collection) // Helps quickly fetch all chats for a user
│   ├── {userId} (Document) // User ID as document
│   │   └── chatIds: [chatId1, chatId2, ...] // List of chat IDs this user is part of


Future<List<Map<String, dynamic>>> getInboxForUser(String userId) async {
final firestore = FirebaseFirestore.instance;

// Step 1: Get list of chat IDs
final userChatsDoc = await firestore.collection('userChats').doc(userId).get();
final chatIds = List<String>.from(userChatsDoc.data()?['chatIds'] ?? []);

if (chatIds.isEmpty) return [];

// Step 2: Get chat documents (batch limit: 10)
final chatsSnapshot = await firestore
.collection('chats')
.where(FieldPath.documentId, whereIn: chatIds.take(10).toList())
.orderBy('lastMessageTime', descending: true)
.get();

final List<Map<String, dynamic>> inboxList = [];

for (final chatDoc in chatsSnapshot.docs) {
final data = chatDoc.data();
final List<dynamic> users = data['users'] ?? [];

    // Step 3: Get the other user in this chat
    final otherUserId = users.firstWhere((id) => id != userId);

    // Step 4: Fetch other user's info
    final otherUserDoc =
        await firestore.collection('users').doc(otherUserId).get();
    final otherUserData = otherUserDoc.data() ?? {};

    // Step 5: Combine all into a map
    inboxList.add({
      'chatId': chatDoc.id,
      'userId': otherUserId,
      'userName': otherUserData['name'] ?? '',
      'userImage': otherUserData['profilePicture'] ?? '',
      'lastMessage': data['lastMessage'] ?? '',
      'lastMessageTime': data['lastMessageTime'],
    });
}

// Step 6: Sort if not sorted (already sorted by Firestore)
return inboxList;
}
