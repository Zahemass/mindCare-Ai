import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme_config.dart';
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
  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
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

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: filePath,
        );

        setState(() => _isRecording = true);
        print('🎙️ Recording started: $filePath');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Microphone permission is required for voice messages',
                style: GoogleFonts.montserrat(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Recording error: $e');
    }
  }

  Future<void> _stopRecordingAndSend() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);

      if (path != null && mounted) {
        print('🎙️ Recording stopped: $path');
        final chatProvider = context.read<ChatProvider>();
        final authProvider = context.read<AuthProvider>();
        final user = authProvider.currentUser;
        await chatProvider.sendVoiceMessage(user?.id ?? 'guest', path);
      }
    } catch (e) {
      print('❌ Stop recording error: $e');
      setState(() => _isRecording = false);
    }
  }

  Future<void> _cancelRecording() async {
    try {
      await _audioRecorder.stop();
      setState(() => _isRecording = false);
      print('🎙️ Recording cancelled');
    } catch (e) {
      setState(() => _isRecording = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    // Scroll to bottom whenever messages change
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? ThemeConfig.darkBackground : const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: isDark ? ThemeConfig.darkSurface : Colors.white,
        elevation: 0,
        leading: widget.showBackButton 
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: isDark ? ThemeConfig.darkTextSecondary : const Color(0xFF9BABBA)),
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
                    color: isDark ? ThemeConfig.darkTextPrimary : const Color(0xFF2C3E50),
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
            icon: Icon(Icons.more_horiz, color: isDark ? ThemeConfig.darkTextSecondary : const Color(0xFF9BABBA)),
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
                color: isDark ? ThemeConfig.primaryTeal.withOpacity(0.1) : const Color(0xFFE8F8F5),
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

          // Recording indicator
          if (_isRecording)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.fiber_manual_record, color: Colors.red, size: 12),
                  const SizedBox(width: 8),
                  Text(
                    'Recording... Tap mic to stop & send',
                    style: GoogleFonts.montserrat(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _cancelRecording,
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.montserrat(
                        color: const Color(0xFF9BABBA),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
          // Input Area
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            decoration: BoxDecoration(
              color: isDark ? ThemeConfig.darkSurface : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              border: isDark ? const Border(top: BorderSide(color: ThemeConfig.darkBorder)) : null,
            ),
            child: Row(
              children: [
                // Voice button
                GestureDetector(
                  onTap: () async {
                    if (_isRecording) {
                      await _stopRecordingAndSend();
                    } else {
                      await _startRecording();
                    }
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _isRecording
                          ? Colors.red.withOpacity(0.1)
                          : isDark ? ThemeConfig.darkCard : const Color(0xFFF2F4F7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop_rounded : Icons.mic_none_rounded,
                      color: _isRecording ? Colors.red : const Color(0xFF9BABBA),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Text input
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? ThemeConfig.darkCard : const Color(0xFFF2F4F7),
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
                const SizedBox(width: 10),
                // Send button
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                    color: message.isUser ? const Color(0xFF48C9B0) : (isDark ? ThemeConfig.darkCard : Colors.white),
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
                      color: message.isUser ? Colors.white : (isDark ? ThemeConfig.darkTextPrimary : const Color(0xFF2C3E50)),
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
