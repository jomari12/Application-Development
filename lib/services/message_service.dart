import 'dart:async';
import '../models/message.dart';
import 'storage_service.dart';

class MessageService {
  static final StreamController<List<Message>> _messagesController = 
      StreamController<List<Message>>.broadcast();
  
  static Stream<List<Message>> get messagesStream => _messagesController.stream;

  static List<Message> getAllMessages() {
    final messagesData = StorageService.getList('messages');
    return messagesData.map((data) => Message.fromMap(data)).toList();
  }

  static List<Message> getConversationMessages(String userId1, String userId2) {
    final messages = getAllMessages();
    return messages.where((message) {
      return (message.senderId == userId1 && message.receiverId == userId2) ||
             (message.senderId == userId2 && message.receiverId == userId1);
    }).toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  static List<Conversation> getUserConversations(String userId) {
    final messages = getAllMessages();
    final Map<String, Conversation> conversations = {};

    for (final message in messages) {
      String otherUserId;
      String otherUserName;
      
      if (message.senderId == userId) {
        otherUserId = message.receiverId;
        otherUserName = message.receiverName;
      } else if (message.receiverId == userId) {
        otherUserId = message.senderId;
        otherUserName = message.senderName;
      } else {
        continue;
      }

      final conversationId = _getConversationId(userId, otherUserId);
      
      if (!conversations.containsKey(conversationId)) {
        conversations[conversationId] = Conversation(
          id: conversationId,
          participantIds: [userId, otherUserId],
          participantNames: [userId == message.senderId ? message.senderName : message.receiverName, otherUserName],
          lastMessage: message.content,
          lastMessageTime: message.timestamp,
          unreadCount: message.receiverId == userId && !message.isRead ? 1 : 0,
        );
      } else {
        final existing = conversations[conversationId]!;
        if (message.timestamp.isAfter(existing.lastMessageTime)) {
          conversations[conversationId] = Conversation(
            id: conversationId,
            participantIds: existing.participantIds,
            participantNames: existing.participantNames,
            lastMessage: message.content,
            lastMessageTime: message.timestamp,
            unreadCount: existing.unreadCount + (message.receiverId == userId && !message.isRead ? 1 : 0),
          );
        }
      }
    }

    return conversations.values.toList()
      ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
  }

  static void sendMessage(String senderId, String senderName, String receiverId, String receiverName, String content) {
    final message = Message(
      id: 'M${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      receiverName: receiverName,
      content: content,
      timestamp: DateTime.now(),
    );

    final messages = getAllMessages();
    messages.add(message);
    
    final messagesData = messages.map((m) => m.toMap()).toList();
    StorageService.setList('messages', messagesData);
    
    _messagesController.add(messages);
  }

  static void markMessagesAsRead(String userId1, String userId2) {
    final messages = getAllMessages();
    bool hasChanges = false;

    for (int i = 0; i < messages.length; i++) {
      if (messages[i].senderId == userId2 && 
          messages[i].receiverId == userId1 && 
          !messages[i].isRead) {
        messages[i] = messages[i].copyWith(isRead: true);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      final messagesData = messages.map((m) => m.toMap()).toList();
      StorageService.setList('messages', messagesData);
      _messagesController.add(messages);
    }
  }

  static String _getConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  static void dispose() {
    _messagesController.close();
  }
}
