import 'package:flutter/material.dart';
import '../../models/message.dart';
import '../../services/message_service.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';

class AdminMessagesScreen extends StatefulWidget {
  const AdminMessagesScreen({super.key});

  @override
  State<AdminMessagesScreen> createState() => _AdminMessagesScreenState();
}

class _AdminMessagesScreenState extends State<AdminMessagesScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _messagesScrollController = ScrollController();
  
  List<Conversation> conversations = [];
  List<Message> currentMessages = [];
  Conversation? selectedConversation;
  String? selectedUserId;
  String? selectedUserName;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    MessageService.messagesStream.listen((_) {
      _loadConversations();
      if (selectedUserId != null) {
        _loadMessages(selectedUserId!);
      }
    });
  }

  void _loadConversations() {
    final currentUser = AuthService().currentUser;
    if (currentUser != null) {
      setState(() {
        conversations = MessageService.getUserConversations(currentUser.id);
      });
    }
  }

  void _loadMessages(String otherUserId) {
    final currentUser = AuthService().currentUser;
    if (currentUser != null) {
      setState(() {
        currentMessages = MessageService.getConversationMessages(currentUser.id, otherUserId);
        selectedUserId = otherUserId;
      });
      
      // Mark messages as read
      MessageService.markMessagesAsRead(currentUser.id, otherUserId);
      
      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_messagesScrollController.hasClients) {
          _messagesScrollController.animateTo(
            _messagesScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || selectedUserId == null) return;

    final currentUser = AuthService().currentUser!;
    MessageService.sendMessage(
      currentUser.id,
      currentUser.name,
      selectedUserId!,
      selectedUserName!,
      _messageController.text.trim(),
    );

    _messageController.clear();
  }

  bool get _isMobile => MediaQuery.of(context).size.width < 768;

  void _selectConversation(String userId, String userName) {
    setState(() {
      selectedUserId = userId;
      selectedUserName = userName;
    });
    _loadMessages(userId);
  }

  void _backToConversationsList() {
    setState(() {
      selectedUserId = null;
      selectedUserName = null;
    });
  }

  Widget _buildConversationsList() {
    return Container(
      width: _isMobile ? double.infinity : 320,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: _isMobile 
            ? null 
            : const Border(right: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                const Icon(Icons.message, color: Color(0xFF2563EB)),
                const SizedBox(width: 12),
                const Text(
                  'Messages',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
                  onPressed: _showNewMessageDialog,
                  tooltip: 'New Message',
                ),
              ],
            ),
          ),
          Expanded(
            child: conversations.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 48, color: Color(0xFF94A3B8)),
                        SizedBox(height: 16),
                        Text(
                          'No conversations yet',
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      final currentUser = AuthService().currentUser!;
                      final otherUserName = conversation.participantNames
                          .firstWhere((name) => name != currentUser.name);
                      final otherUserId = conversation.participantIds
                          .firstWhere((id) => id != currentUser.id);
                      
                      final isSelected = selectedUserId == otherUserId;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2563EB).withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF2563EB),
                            child: Text(
                              otherUserName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                          title: Text(
                            otherUserName,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                            ),
                          ),
                          subtitle: Text(
                            conversation.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Color(0xFF64748B)),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatTime(conversation.lastMessageTime),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              if (conversation.unreadCount > 0)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${conversation.unreadCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              selectedConversation = conversation;
                              selectedUserName = otherUserName;
                            });
                            _selectConversation(otherUserId, otherUserName);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    if (selectedUserId == null) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.chat, size: 64, color: Color(0xFF94A3B8)),
              const SizedBox(height: 16),
              Text(
                'Select a conversation to start messaging',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        children: [
          // Chat Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                if (_isMobile)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF2563EB)),
                    onPressed: _backToConversationsList,
                  ),
                CircleAvatar(
                  backgroundColor: const Color(0xFF2563EB),
                  child: Text(
                    selectedUserName?.substring(0, 1).toUpperCase() ?? '',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedUserName ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Messages Area
          Expanded(
            child: Container(
              color: const Color(0xFFF8FAFC),
              child: currentMessages.isEmpty
                  ? const Center(
                      child: Text(
                        'No messages yet. Start the conversation!',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    )
                  : ListView.builder(
                      controller: _messagesScrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: currentMessages.length,
                      itemBuilder: (context, index) {
                        final message = currentMessages[index];
                        final currentUser = AuthService().currentUser!;
                        final isMe = message.senderId == currentUser.id;
                        
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            constraints: BoxConstraints(
                              maxWidth: _isMobile 
                                  ? MediaQuery.of(context).size.width * 0.8
                                  : 300,
                            ),
                            decoration: BoxDecoration(
                              color: isMe ? const Color(0xFF2563EB) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.content,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : const Color(0xFF1E293B),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(message.timestamp),
                                  style: TextStyle(
                                    color: isMe ? Colors.white.withOpacity(0.7) : const Color(0xFF94A3B8),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          
          // Message Input
          Container(
            padding: EdgeInsets.all(_isMobile ? 12 : 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFF2563EB)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    onPressed: _sendMessage,
                    mini: true,
                    backgroundColor: const Color(0xFF2563EB),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNewMessageDialog() {
    final users = StorageService.getList('users');
    final currentUser = AuthService().currentUser!;
    final otherUsers = users.where((user) => 
        user['id'] != currentUser.id && user['role'] == 'customer').toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Message'),
        content: SizedBox(
          width: _isMobile ? double.maxFinite : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select a customer to message:'),
              const SizedBox(height: 16),
              ...otherUsers.map((user) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF2563EB),
                  child: Text(
                    user['name'].substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(user['name']),
                subtitle: Text(user['email']),
                onTap: () {
                  Navigator.pop(context);
                  _selectConversation(user['id'], user['name']);
                },
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messagesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isMobile) {
      // Mobile layout - show either conversations list or chat area
      return selectedUserId == null
          ? _buildConversationsList()
          : _buildChatArea();
    } else {
      // Desktop layout - show both side by side
      return Row(
        children: [
          _buildConversationsList(),
          _buildChatArea(),
        ],
      );
    }
  }
}