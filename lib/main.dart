import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; 
import 'package:flutter/scheduler.dart'; 
// import 'dart:math' as math;

const double kTabletBreakpoint = 600.0;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Helpdesk Chat MST',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal), 
        useMaterial3: true,
      ),
      home: const ChatResponsiveLayout(),
    );
  }
}

class Conversation {
  final String name;
  final String lastMessage; 
  final String status; 
  final String time; 
  final Color avatarColor;

  Conversation({
    required this.name,
    required this.lastMessage,
    required this.status,
    required this.time,
    required this.avatarColor,
  });
}

final List<Conversation> mockConversations = [
  //pemrofilan sesuai mock-up 
  Conversation(
      name: 'Cameron Williamson',
      lastMessage: "Can't log in", // Problem
      status: 'Open',
      time: '9:22 AM',
      avatarColor: Colors.red.shade400),
  Conversation(
      name: 'Kristen Watson',
      lastMessage: 'Error message',
      status: 'Tue',
      time: '9:24 AM',
      avatarColor: Colors.green.shade400),
  Conversation(
      name: 'Kathryn Murphy',
      lastMessage: 'Payment issue',
      status: 'Tue',
      time: '9:25 AM',
      avatarColor: Colors.purple.shade400),
  Conversation(
      name: 'Ralph Edwards',
      lastMessage: 'Account assistance',
      status: 'Mon',
      time: '10:01 AM',
      avatarColor: Colors.indigo.shade400),
];

//DAFTAR KONTAK

class ConversationListScreen extends StatelessWidget {
  final Function(Conversation) onConversationSelected;
  final Conversation? selectedConversation;

  const ConversationListScreen({
    super.key,
    required this.onConversationSelected,
    this.selectedConversation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (MediaQuery.of(context).size.width < kTabletBreakpoint)
          ? AppBar(
              title: const Text('Helpdesk Chat'),
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
              ],
            )
          : null, 

      body: Column(
        children: [
          if (MediaQuery.of(context).size.width >= kTabletBreakpoint)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  const Text(
                    'Helpdesk Chat', 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
                ],
              ),
            ),
          
          Expanded(
            child: ListView.builder(
              itemCount: mockConversations.length,
              itemBuilder: (context, index) {
                final conversation = mockConversations[index];
                final isSelected = conversation == selectedConversation;

                return _buildConversationTile(context, conversation, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(
      BuildContext context, Conversation conversation, bool isSelected) {
    
    Color statusColor = Colors.grey;
    if (conversation.status == 'Open') {
      statusColor = Colors.teal.shade400; 
    }

    return ListTile(
      onTap: () => onConversationSelected(conversation),
      tileColor: isSelected ? Colors.blue.shade50 : null,
      
      leading: CircleAvatar(
        backgroundColor: conversation.avatarColor,
        child: Text(
          conversation.name[0],
          style: const TextStyle(color: Colors.white),
        ),
      ),
      
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            conversation.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            overflow: TextOverflow.ellipsis, 
          ),
          Text(
            conversation.lastMessage, 
            style: TextStyle(fontWeight: FontWeight.normal, color: Colors.grey.shade600, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (conversation.status == 'Open')
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                conversation.status,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            )
          else 
            Text(conversation.status, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.normal)),
        ],
      ),
    );
  }
}

//LAYER KANAN (kolom chat)

class ChatScreen extends StatefulWidget {
  final Conversation? conversation;
  final bool isMobile;
  final Function() onBack;

  const ChatScreen({
    super.key,
    required this.conversation,
    this.isMobile = false,
    required this.onBack,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final String _apiKey = "YOUR_GEMINI_API_KEY_HERE";

  bool _isLoading = false;
  final List<Map<String, String>> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeMessages(); 
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.conversation != widget.conversation) {
      _initializeMessages();
    }
  }

  void _initializeMessages() {
    _messages.clear();
    if (widget.conversation == null && !widget.isMobile) {
        _messages.add({'sender': 'ai', 'text': 'Pilih percakapan dari daftar di sebelah kiri untuk melihat dan merespons masalah customer.'});
    } else {
       final initialProblem = widget.conversation?.lastMessage ?? 'Selamat Pagi, saya tidak bisa login ke akun saya. Mohon bantuannya.';
       
       _messages.add({'sender': 'ai', 'text': initialProblem});
    }
    _scrollToBottom();
  }

  Future<void> _handleSendPressed() async {
    final adminMessage = _textController.text.trim(); 
    if (adminMessage.isEmpty) return;

    _textController.clear();

    setState(() {
      _messages.add({'sender': 'admin', 'text': adminMessage});
      _isLoading = true; 
    });

    _scrollToBottom();

  //pemanggilan asset foto (manual bukan ai)
    if (adminMessage.toLowerCase().contains('kirim foto') || adminMessage.toLowerCase().contains('kirim gambar')) {
      await Future.delayed(const Duration(seconds: 1)); 
      setState(() {
        const imagePath = 'assets/images/errortelematika.png';
        
        _messages.add({
          'sender': 'ai', 
          'text': "Baik, ini adalah screenshot masalah yang saya alami.\n[IMAGE_ASSET]$imagePath" 
        });
        _isLoading = false;
      });
      _scrollToBottom();
      return; 
    }

    try {
      final customerResponse = await _getGeminiResponse(adminMessage);
      
      setState(() {
        _messages.add({'sender': 'ai', 'text': customerResponse});
        _isLoading = false; 
      });
      _scrollToBottom();
      
    } catch (e) {
      String errorMessage = "Gagal terhubung ke AI Customer: Layanan sibuk. Coba lagi.";
      if (e.toString().contains("Respon AI tidak lengkap")) {
          errorMessage = "AI Customer tidak merespons. Mungkin solusi Admin terlalu kompleks.";
      } else if (e.toString().contains("TimeoutException")) {
          errorMessage = "Koneksi ke AI Customer timeout (30s). Coba lagi.";
      }
      
      setState(() {
        _messages.add({'sender': 'ai', 'text': errorMessage});
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  Future<String> _getGeminiResponse(String adminMessage) async {
    final model = 'gemini-2.5-flash';
    final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$_apiKey');

    final systemPrompt = "Anda adalah Customer yang mengalami masalah login di aplikasi. Anda menerima solusi dari Admin. Balas dengan singkat, realistis, dan menggunakan Bahasa Indonesia. Jika solusi Admin benar, katakan 'Terima kasih, masalah sudah teratasi.' Jika solusi Admin salah atau tidak lengkap, balas dengan keluhan atau pertanyaan lebih lanjut. Solusi Admin: $adminMessage";

    final body = jsonEncode({
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": systemPrompt}
          ]
        }
      ],
      "generationConfig": {
        "maxOutputTokens": 200, 
      }
    });

  //maksimal waktu ai utk merespon 30 detik, jika >30 maka error
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: body,
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final candidates = data['candidates'] as List<dynamic>?;
      
      if (candidates == null || candidates.isEmpty) {
          throw Exception("Respon AI tidak lengkap.");
      }

      final text = candidates[0]['content']['parts'][0]['text'] as String?;

      if (text == null || text.isEmpty) {
          throw Exception("Sistem AI tidak dapat memproses jawaban saat ini.");
      }

      return text;
    } else {
      throw Exception('Status ${response.statusCode}: ${response.body}');
    }
  }

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  Widget _buildChatBubble(Map<String, String> message) {
    final bool isAdmin = message['sender'] == 'admin';
    final Color bubbleColor = isAdmin ? Colors.blue.shade600 : Colors.grey[200]!;
    final Color textColor = isAdmin ? Colors.white : Colors.black87;
    
    final messageText = message['text']!;
    const imageKeyword = '[IMAGE_ASSET]'; 

    //jika pesan dalam imagekeyword terjadi yaitu "kirim", maka kondisi dibwh dijalankan
    if (messageText.contains(imageKeyword)) {
      final parts = messageText.split(imageKeyword);
      final preText = parts[0];
      final imagePath = parts.length > 1 ? parts[1].trim() : null;

      return Align(
        alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75), 
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(12).copyWith(
              topLeft: isAdmin ? const Radius.circular(12) : Radius.zero,
              topRight: isAdmin ? Radius.zero : const Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (preText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(preText, style: TextStyle(color: textColor)),
                ),
              if (imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.red.shade100,
                      child: const Text('Gagal memuat gambar (Aset tidak ditemukan).', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    
    //kondisi jika pesan hanya text
    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft, 
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(12).copyWith(
            topLeft: isAdmin ? const Radius.circular(12) : Radius.zero, 
            topRight: isAdmin ? Radius.zero : const Radius.circular(12), 
          ),
        ),
        child: Text(
          messageText,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.conversation == null && !widget.isMobile) {
      return Center(
        child: Text('Pilih percakapan dari daftar di sebelah kiri untuk melihat dan merespons masalah customer.', style: TextStyle(color: Colors.grey.shade500)),
      );
    }
    
    return Scaffold(
      appBar: widget.isMobile
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
              title: Text(widget.conversation?.name ?? 'Helpdesk'),
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
              ],
            )
          : null,

      body: Column(
        children: [
          if (!widget.isMobile && widget.conversation != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
              ),
              child: Row(
                children: [
                  //avatar customer (karena tidak ada asset wajah customer)
                  CircleAvatar(
                    backgroundColor: widget.conversation!.avatarColor,
                    child: Text(widget.conversation!.name[0], style: const TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.conversation!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), // Nama Customer
                      Text(widget.conversation!.lastMessage, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)), // Problem
                    ],
                  ),
                  const Spacer(),
                  //status open (hanya icon bukan button, tidak dapat ditekan)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.conversation!.status == 'Open' ? Colors.teal.shade400 : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.conversation!.status,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
                ],
              ),
            ),
          
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  return _buildChatBubble(_messages[index]);
                } else {
                  // Indikator loading AI
                  return Container(
                    padding: const EdgeInsets.all(12),
                    alignment: Alignment.centerLeft, 
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start, 
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Customer sedang merespons...'),
                      ],
                    ),
                  );
                }
              },
            ),
          ),

          //utk input text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Message',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 0),
                    ),
                    onSubmitted: (text) => _handleSendPressed(),
                    enabled: !_isLoading,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _isLoading ? null : _handleSendPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// 3. LAYOUT RESPONSIVE (Pintu Masuk Utama)
// ----------------------------------------------------------------------

class ChatResponsiveLayout extends StatefulWidget {
  const ChatResponsiveLayout({super.key});

  @override
  State<ChatResponsiveLayout> createState() => _ChatResponsiveLayoutState();
}

class _ChatResponsiveLayoutState extends State<ChatResponsiveLayout> {
  Conversation? _selectedConversation;
  int _currentView = 0; 

  void _selectConversation(Conversation conversation) {
    setState(() {
      _selectedConversation = conversation;
      _currentView = 1;
    });
  }

  void _goBack() {
    setState(() {
      _currentView = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= kTabletBreakpoint;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                // PERBAIKAN LEBAR PANEL KIRI: Fix 300px
                SizedBox(
                  width: 300, 
                  child: ConversationListScreen(
                    onConversationSelected: _selectConversation,
                    selectedConversation: _selectedConversation,
                  ),
                ),
                VerticalDivider(width: 1, color: Colors.grey.shade300),
                Expanded(
                  child: ChatScreen(
                    conversation: _selectedConversation,
                    onBack: _goBack, 
                    isMobile: false,
                  ),
                ),
              ],
            ),
          );
        } else {
          return IndexedStack(
            index: _currentView,
            children: [
              ConversationListScreen(
                onConversationSelected: _selectConversation,
                selectedConversation: _selectedConversation,
              ),
              ChatScreen(
                conversation: _selectedConversation,
                onBack: _goBack,
                isMobile: true,
              ),
            ],
          );
        }
      },
    );
  }
}