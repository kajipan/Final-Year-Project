import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! I am MechNow AI Assistant. Describe your vehicle issue and I will help you! 🚗🔧',
      'isBot': true,
    },
  ];

  final Map<String, String> _autoReplies = {
    'battery': '🔋 Battery Issue Detected!\n\n• Check if headlights are dim\n• Try jump starting\n• Battery may need replacement\n\nShall I find a mechanic nearby?',
    'tyre': '🔄 Tyre Issue Detected!\n\n• Move to safe location\n• Turn on hazard lights\n• Do not drive on flat tyre\n\nShall I find a mechanic nearby?',
    'engine': '⚙️ Engine Issue Detected!\n\n• Stop the vehicle safely\n• Check engine temperature\n• Do not continue driving\n\nShall I find a mechanic nearby?',
    'overheating': '🌡️ Overheating Detected!\n\n• Pull over immediately\n• Turn off AC\n• Let engine cool 30 mins\n\nShall I find a mechanic nearby?',
    'brake': '🛑 Brake Issue Detected!\n\n• This is URGENT - stop safely\n• Use handbrake if needed\n• Do not drive\n\nShall I find a mechanic nearby?',
    'noise': '🔊 Strange Noise Detected!\n\n• Note when noise occurs\n• Check if grinding/knocking\n• Could be engine/brake issue\n\nShall I find a mechanic nearby?',
  };

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isBot': false});
    });

    _messageController.clear();

    // Auto reply based on keywords
    String reply = '🤔 I understand you have a vehicle issue. Can you describe more?\n\nCommon issues:\n• Battery\n• Tyre\n• Engine\n• Overheating\n• Brake\n• Strange noise';

    final lowerText = text.toLowerCase();
    for (final key in _autoReplies.keys) {
      if (lowerText.contains(key)) {
        reply = _autoReplies[key]!;
        break;
      }
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _messages.add({'text': reply, 'isBot': true});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B00),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 16,
              child: Icon(Icons.smart_toy, color: Color(0xFFFF6B00), size: 18),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MechNow AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Always Online',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Quick Issue Buttons
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.orange[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Select Issue:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _quickButton('🔋 Battery'),
                      _quickButton('🔄 Tyre'),
                      _quickButton('⚙️ Engine'),
                      _quickButton('🌡️ Overheating'),
                      _quickButton('🛑 Brake'),
                      _quickButton('🔊 Noise'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _messageBubble(message['text'], message['isBot']);
              },
            ),
          ),

          // Input Field
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 5),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Describe your vehicle issue...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6B00),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickButton(String label) {
    return GestureDetector(
      onTap: () {
        _messageController.text = label.split(' ').last;
        _sendMessage();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B00),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  Widget _messageBubble(String text, bool isBot) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBot) ...[
            const CircleAvatar(
              backgroundColor: Color(0xFFFF6B00),
              radius: 16,
              child: Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isBot ? Colors.grey[100] : const Color(0xFFFF6B00),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isBot ? 0 : 16),
                  bottomRight: Radius.circular(isBot ? 16 : 0),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isBot ? Colors.black87 : Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}