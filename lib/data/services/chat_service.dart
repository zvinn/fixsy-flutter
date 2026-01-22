import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/message_model.dart';
import '../models/conversation_model.dart';

/// Chat Service
/// Handles all chat-related operations with Firestore Realtime
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const String _conversationsCollection = 'conversations';
  static const String _messagesSubcollection = 'messages';

  /// Create or get existing conversation
  Future<Conversation> getOrCreateConversation({
    required String bookingId,
    required String userId,
    required String userName,
    required String technicianId,
    required String technicianName,
  }) async {
    try {
      // Check if conversation exists for this booking
      final existingConv = await _firestore
          .collection(_conversationsCollection)
          .doc(bookingId)
          .get();

      if (existingConv.exists) {
        final data = existingConv.data()!;
        data['id'] = existingConv.id;
        return Conversation.fromJson(data);
      }

      // Create new conversation
      final conversation = Conversation(
        id: bookingId,
        bookingId: bookingId,
        userId: userId,
        userName: userName,
        technicianId: technicianId,
        technicianName: technicianName,
        lastMessageTime: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(_conversationsCollection)
          .doc(bookingId)
          .set(conversation.toJson());

      return conversation;
    } catch (e) {
      throw Exception('فشل إنشاء المحادثة: $e');
    }
  }

  /// Send text message
  Future<Message> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String content,
  }) async {
    try {
      final messageRef = _firestore
          .collection(_conversationsCollection)
          .doc(conversationId)
          .collection(_messagesSubcollection)
          .doc();

      final message = Message(
        id: messageRef.id,
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        content: content,
        type: MessageType.text,
        timestamp: DateTime.now(),
      );

      await messageRef.set(message.toJson());

      // Update conversation
      await _updateConversation(conversationId, content, senderId);

      return message;
    } catch (e) {
      throw Exception('فشل إرسال الرسالة: $e');
    }
  }

  /// Send image message
  Future<Message> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required XFile imageFile,
  }) async {
    try {
      // Upload image to Firebase Storage
      final imageUrl = await _uploadImage(conversationId, imageFile);

      final messageRef = _firestore
          .collection(_conversationsCollection)
          .doc(conversationId)
          .collection(_messagesSubcollection)
          .doc();

      final message = Message(
        id: messageRef.id,
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        content: 'صورة',
        type: MessageType.image,
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
      );

      await messageRef.set(message.toJson());

      // Update conversation
      await _updateConversation(conversationId, '📷 صورة', senderId);

      return message;
    } catch (e) {
      throw Exception('فشل إرسال الصورة: $e');
    }
  }

  /// Upload image to Firebase Storage
  Future<String> _uploadImage(String conversationId, XFile imageFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'chat_images/$conversationId/$timestamp.jpg';
      
      final file = File(imageFile.path);
      final ref = _storage.ref().child(fileName);
      
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('فشل رفع الصورة: $e');
    }
  }

  /// Update conversation with last message
  Future<void> _updateConversation(
    String conversationId,
    String lastMessage,
    String senderId,
  ) async {
    try {
      final conversationRef = _firestore
          .collection(_conversationsCollection)
          .doc(conversationId);

      final conversation = await conversationRef.get();
      if (!conversation.exists) return;

      final data = conversation.data()!;
      final unreadCount = Map<String, int>.from(data['unreadCount'] ?? {});

      // Increment unread for receiver
      final receiverId = data['userId'] == senderId 
          ? data['technicianId'] 
          : data['userId'];
      unreadCount[receiverId] = (unreadCount[receiverId] ?? 0) + 1;

      await conversationRef.update({
        'lastMessage': lastMessage,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': unreadCount,
      });
    } catch (e) {
      print('Error updating conversation: $e');
    }
  }

  /// Stream messages for a conversation (realtime)
  Stream<List<Message>> streamMessages(String conversationId) {
    return _firestore
        .collection(_conversationsCollection)
        .doc(conversationId)
        .collection(_messagesSubcollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Message.fromJson(data);
      }).toList();
    });
  }

  /// Stream user conversations
  Stream<List<Conversation>> streamUserConversations(String userId) {
    return _firestore
        .collection(_conversationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Conversation.fromJson(data);
      }).toList();
    });
  }

  /// Stream technician conversations
  Stream<List<Conversation>> streamTechnicianConversations(String technicianId) {
    return _firestore
        .collection(_conversationsCollection)
        .where('technicianId', isEqualTo: technicianId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Conversation.fromJson(data);
      }).toList();
    });
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(
    String conversationId,
    String userId,
  ) async {
    try {
      // Get all unread messages
      final messagesQuery = await _firestore
          .collection(_conversationsCollection)
          .doc(conversationId)
          .collection(_messagesSubcollection)
          .where('senderId', isNotEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();

      // Mark all as read
      for (final doc in messagesQuery.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();

      // Reset unread count for this user
      await _firestore
          .collection(_conversationsCollection)
          .doc(conversationId)
          .update({
        'unreadCount.$userId': 0,
      });
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  /// Get conversation by ID
  Future<Conversation?> getConversation(String conversationId) async {
    try {
      final doc = await _firestore
          .collection(_conversationsCollection)
          .doc(conversationId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;
      return Conversation.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      // Delete all messages
      final messages = await _firestore
          .collection(_conversationsCollection)
          .doc(conversationId)
          .collection(_messagesSubcollection)
          .get();

      final batch = _firestore.batch();
      for (final doc in messages.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // Delete conversation
      await _firestore
          .collection(_conversationsCollection)
          .doc(conversationId)
          .delete();
    } catch (e) {
      throw Exception('فشل حذف المحادثة: $e');
    }
  }

  /// Send system message (e.g., "Booking accepted")
  Future<void> sendSystemMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      final messageRef = _firestore
          .collection(_conversationsCollection)
          .doc(conversationId)
          .collection(_messagesSubcollection)
          .doc();

      final message = Message(
        id: messageRef.id,
        conversationId: conversationId,
        senderId: 'system',
        senderName: 'نظام Fixsy',
        content: content,
        type: MessageType.system,
        timestamp: DateTime.now(),
        isRead: true,
      );

      await messageRef.set(message.toJson());
    } catch (e) {
      print('Error sending system message: $e');
    }
  }
}
