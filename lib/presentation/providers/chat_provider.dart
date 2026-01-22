import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/message_model.dart';
import '../../data/models/conversation_model.dart';
import '../../data/services/chat_service.dart';

/// Chat Provider
/// Manages chat state and operations
class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  final ImagePicker _imagePicker = ImagePicker();

  List<Conversation> _conversations = [];
  List<Message> _currentMessages = [];
  Conversation? _currentConversation;
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;

  // Getters
  List<Conversation> get conversations => _conversations;
  List<Message> get currentMessages => _currentMessages;
  Conversation? get currentConversation => _currentConversation;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;

  /// Get or create conversation
  Future<Conversation?> getOrCreateConversation({
    required String bookingId,
    required String userId,
    required String userName,
    required String technicianId,
    required String technicianName,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      _currentConversation = await _chatService.getOrCreateConversation(
        bookingId: bookingId,
        userId: userId,
        userName: userName,
        technicianId: technicianId,
        technicianName: technicianName,
      );

      _isLoading = false;
      notifyListeners();

      return _currentConversation;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Send text message
  Future<bool> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String content,
  }) async {
    if (content.trim().isEmpty) return false;

    try {
      _isSending = true;
      notifyListeners();

      await _chatService.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        content: content.trim(),
      );

      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  /// Send image message
  Future<bool> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
  }) async {
    try {
      // Pick image
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return false;

      _isSending = true;
      notifyListeners();

      await _chatService.sendImageMessage(
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        imageFile: image,
      );

      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  /// Stream messages for current conversation
  Stream<List<Message>> streamMessages(String conversationId) {
    return _chatService.streamMessages(conversationId);
  }

  /// Stream user conversations
  Stream<List<Conversation>> streamUserConversations(String userId) {
    return _chatService.streamUserConversations(userId);
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    try {
      await _chatService.markMessagesAsRead(conversationId, userId);
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset current conversation
  void resetCurrentConversation() {
    _currentConversation = null;
    _currentMessages = [];
    notifyListeners();
  }
}
