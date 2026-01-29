import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../providers/auth_provider.dart';
import '../../providers/journal_provider.dart';
import '../../models/journal_entry.dart';
import '../../config/theme_config.dart';

class JournalEntryScreen extends StatefulWidget {
  final String? journalId;
  const JournalEntryScreen({super.key, this.journalId});

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final _contentController = TextEditingController();
  final _titleController = TextEditingController(); // We'll auto-generate or use a default
  String _currentPrompt = "What made you smile today?";
  String? _selectedEmoji;
  late DateTime _timestamp;
  bool _isEditing = false;

  final List<String> _prompts = [
    "What made you smile today?",
    "What are you grateful for right now?",
    "What's one thing you want to achieve tomorrow?",
    "Describe a challenge you faced today and how you handled it.",
    "What's a positive thought you had today?",
  ];

  final List<String> _emojis = ['😊', '😌', '😐', '😔', '😫'];

  @override
  void initState() {
    super.initState();
    _timestamp = DateTime.now();
    if (widget.journalId != null) {
      _isEditing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final entry = context.read<JournalProvider>().getEntryById(widget.journalId!);
        if (entry != null) {
          setState(() {
            _contentController.text = entry.content;
            _titleController.text = entry.title;
            _timestamp = entry.createdAt;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _shufflePrompt() {
    setState(() {
      _currentPrompt = (_prompts..shuffle()).first;
    });
  }

  Future<void> _saveJournal() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something first')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final journalProvider = context.read<JournalProvider>();

    final entry = JournalEntry(
      id: widget.journalId ?? const Uuid().v4(),
      userId: authProvider.currentUser!.id,
      title: _titleController.text.isEmpty ? 'Daily Journal' : _titleController.text,
      content: _contentController.text.trim(),
      createdAt: _timestamp,
      updatedAt: DateTime.now(),
    );

    if (_isEditing) {
      await journalProvider.updateEntry(entry);
    } else {
      await journalProvider.addEntry(entry);
    }

    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, MMMM dd • hh:mm a').format(_timestamp);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50), size: 16),
                onPressed: () => context.pop(),
              ),
            ),
          ),
        ),
        title: Text(
          'Dear Journal...',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2C3E50),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: _saveJournal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConfig.primaryTeal,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Text(
                    'Save',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI Prompt Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9F8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE0F2F1)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB2DFDB).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Color(0xFF48C9B0),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI COMPANION PROMPT',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF48C9B0),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _currentPrompt,
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2C3E50),
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: _shufflePrompt,
                                child: Row(
                                  children: [
                                    const Icon(Icons.refresh_rounded, size: 14, color: Color(0xFFBDC3C7)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Try another prompt',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13,
                                        color: const Color(0xFFBDC3C7),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Timestamp
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFFBDC3C7)),
                      const SizedBox(width: 8),
                      Text(
                        dateStr,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: const Color(0xFFBDC3C7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Text Area
                  TextField(
                    controller: _contentController,
                    maxLines: null,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      color: const Color(0xFF2C3E50),
                      height: 1.6,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Start typing your thoughts here...',
                      hintStyle: GoogleFonts.montserrat(
                        fontSize: 18,
                        color: const Color(0xFFE0E0E0),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _emojis.map((emoji) {
                      final isSelected = _selectedEmoji == emoji;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedEmoji = emoji),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: isSelected ? Border.all(color: ThemeConfig.primaryTeal, width: 2) : null,
                          ),
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 16),
                Container(width: 1, height: 24, color: const Color(0xFFE0E0E0)),
                const SizedBox(width: 16),
                Icon(Icons.camera_alt_outlined, color: Colors.grey[400], size: 24),
                const SizedBox(width: 24),
                Icon(Icons.mic_none_rounded, color: Colors.grey[400], size: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
