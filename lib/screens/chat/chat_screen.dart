import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/chat_message.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends StatefulWidget {
  final bool showBackButton;
  const ChatScreen({super.key, this.showBackButton = true});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    // Scroll to bottom whenever messages change
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: widget.showBackButton 
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF9BABBA)),
              onPressed: () => context.pop(),
            )
          : null,
        title: Row(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=mindie'),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF48C9B0),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mindie',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF2C3E50),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.circle, color: Color(0xFF48C9B0), size: 6),
                    const SizedBox(width: 4),
                    Text(
                      'Always here for you',
                      style: GoogleFonts.montserrat(
                        color: const Color(0xFF48C9B0),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Color(0xFF9BABBA)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Disclaimer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8F5),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFF48C9B0).withOpacity(0.3)),
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'DISCLAIMER: ',
                      style: GoogleFonts.montserrat(
                        color: const Color(0xFF16A085),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'Mindie is an AI companion, not a medical professional. If in crisis, please seek immediate help.',
                      style: GoogleFonts.montserrat(
                        color: const Color(0xFF16A085),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: chatProvider.messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'TODAY, ${DateFormat('h:mm a').format(DateTime.now())}',
                        style: GoogleFonts.montserrat(
                          color: const Color(0xFF9BABBA),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  );
                }
                
                final message = chatProvider.messages[index - 1];
                return _ChatBubble(message: message);
              },
            ),
          ),
          
          if (chatProvider.isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 8),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=mindie'),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mindie is typing...',
                    style: GoogleFonts.montserrat(
                      color: const Color(0xFF9BABBA),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            
          // Input Area
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F7),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.sentiment_satisfied_alt, color: Color(0xFF9BABBA)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Type a message...',
                                  hintStyle: GoogleFonts.montserrat(
                                    color: const Color(0xFF9BABBA),
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: const Color(0xFF2C3E50),
                                ),
                                onSubmitted: (value) async {
                                  if (value.isNotEmpty) {
                                    final text = _messageController.text;
                                    _messageController.clear();
                                    await chatProvider.sendMessage(user?.id ?? 'guest', text);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () async {
                        if (_messageController.text.isNotEmpty) {
                          final text = _messageController.text;
                          _messageController.clear();
                          await chatProvider.sendMessage(user?.id ?? 'guest', text);
                        }
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFF48C9B0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.mic_none_rounded, color: Color(0xFF9BABBA)),
                        onPressed: () {}),
                    IconButton(
                        icon: const Icon(Icons.image_outlined, color: Color(0xFF9BABBA)),
                        onPressed: () {}),
                    IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF9BABBA)),
                        onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!message.isUser)
                const CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=mindie'),
                ),
              if (!message.isUser) const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isUser ? const Color(0xFF48C9B0) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(message.isUser ? 20 : 5),
                      bottomRight: Radius.circular(message.isUser ? 5 : 20),
                    ),
                    boxShadow: [
                      if (!message.isUser)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: GoogleFonts.montserrat(
                      color: message.isUser ? Colors.white : const Color(0xFF2C3E50),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (message.isUser)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Read ${DateFormat('h:mm a').format(message.timestamp)}',
                style: GoogleFonts.montserrat(
                  color: const Color(0xFF9BABBA),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
