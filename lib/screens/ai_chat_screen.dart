// ai_chat_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

const Color kPrimary = Color(0xFFFF6B00);
const String kBaseUrl = 'http://10.0.2.2:8081'; // unga backend host different-a irundha maathunga

enum ChatStage {
  notStarted,
  greeted,
  awaitingBikePhoto,
  bikeTypeConfirm,
  awaitingIssueSelect,
  askingSymptoms,
  showingSolution,
}

class AiChatScreen extends StatefulWidget {
  final int? userId;
  final String? userName;
  const AiChatScreen({super.key, this.userId, this.userName});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  ChatStage _stage = ChatStage.notStarted;
  Map<String, dynamic>? _issuesData;

  String? _detectedBodyType;
  String? _selectedIssueKey;
  List<Map<String, dynamic>> _pendingQuestions = [];
  int _questionIndex = 0;
  final Map<String, bool> _answers = {};
  Map<String, dynamic>? _matchedCause;
  bool _isBusy = false;

  static const List<Map<String, String>> _issueOptions = [
    {'key': 'battery', 'label': '🔋 Battery'},
    {'key': 'tire', 'label': '🔄 Tire'},
    {'key': 'engine', 'label': '⚙️ Engine'},
    {'key': 'overheating', 'label': '🌡️ Overheating'},
    {'key': 'brake', 'label': '🛑 Brake'},
    {'key': 'strange_noise', 'label': '🔊 Strange Noise'},
    {'key': 'electrical', 'label': '💡 Electrical'},
    {'key': 'other', 'label': '🔧 Other'},
  ];

  static const List<Map<String, String>> _bodyTypeOptions = [
    {'key': 'scooter', 'label': 'Scooter'},
    {'key': 'commuter_standard', 'label': 'Commuter / Standard'},
    {'key': 'sports_commuter', 'label': 'Sports Commuter'},
  ];

  @override
  void initState() {
    super.initState();
    _loadIssuesJson();
    // No auto messages here anymore — bot replies only when user talks first.
  }

  Future<void> _loadIssuesJson() async {
    try {
      final raw = await rootBundle.loadString('assets/issues.json');
      _issuesData = jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Could not load issues.json: $e');
    }
  }

  void _botSay(String text, {List<Widget>? quickReplies}) {
    setState(() {
      _messages.add({'text': text, 'isBot': true, 'quickReplies': quickReplies});
    });
    _scrollToBottom();
  }

  void _userSay(String text) {
    setState(() {
      _messages.add({'text': text, 'isBot': false});
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickBikeImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;
    _userSay('📷 [Photo uploaded]');
    setState(() => _isBusy = true);
    _botSay('Analyzing your bike photo...');

    try {
      final bodyType = await _classifyBikeType(File(picked.path));
      setState(() {
        _detectedBodyType = bodyType;
        _stage = ChatStage.bikeTypeConfirm;
        _isBusy = false;
      });
      _botSay(
        "Oh, it's a ${_labelForBodyType(bodyType)}! Is this correct?",
        quickReplies: [
          _quickReplyChip('✅ Yes, correct', () => _confirmBodyType(bodyType)),
          _quickReplyChip('✏️ No, let me select', _showManualBodyTypeSelect),
        ],
      );
    } catch (e) {
      setState(() => _isBusy = false);
      _botSay("I couldn't reach the bike-detection service. Please select your bike type manually:");
      _showManualBodyTypeSelect();
    }
  }

  Future<String> _classifyBikeType(File imageFile) async {
    final uri = Uri.parse('$kBaseUrl/api/chat/classify-bike');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    final streamed = await request.send().timeout(const Duration(seconds: 20));
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['bodyType'] as String;
    }
    throw Exception('classify-bike failed: ${response.statusCode}');
  }

  String _labelForBodyType(String key) {
    return _bodyTypeOptions.firstWhere((b) => b['key'] == key, orElse: () => {'label': key})['label']!;
  }

  void _showManualBodyTypeSelect() {
    _botSay(
      'Please select your bike type:',
      quickReplies: _bodyTypeOptions
          .map((b) => _quickReplyChip(b['label']!, () => _confirmBodyType(b['key']!)))
          .toList(),
    );
  }

  void _confirmBodyType(String bodyType) {
    _userSay(_labelForBodyType(bodyType));
    setState(() {
      _detectedBodyType = bodyType;
      _stage = ChatStage.awaitingIssueSelect;
    });
    _botSay(
      'Got it! What type of issue are you facing?',
      quickReplies: _issueOptions
          .map((i) => _quickReplyChip(i['label']!, () => _selectIssue(i['key']!, i['label']!)))
          .toList(),
    );
  }

  void _selectIssue(String key, String label) {
    _userSay(label);
    _answers.clear();
    _questionIndex = 0;
    _matchedCause = null;
    _selectedIssueKey = key;

    final issueBlock = _issuesData?[key] as Map<String, dynamic>?;
    _pendingQuestions = (issueBlock?['questions'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

    if (key == 'other' || _pendingQuestions.isEmpty) {
      setState(() => _stage = ChatStage.askingSymptoms);
      _botSay('Please describe the issue in your own words.');
      return;
    }

    setState(() => _stage = ChatStage.askingSymptoms);
    _askNextQuestion();
  }

  void _askNextQuestion() {
    if (_questionIndex >= _pendingQuestions.length) {
      _computeDiagnosis();
      return;
    }
    final q = _pendingQuestions[_questionIndex];
    _botSay(
      q['text'] as String,
      quickReplies: [
        _quickReplyChip('Yes', () => _answerQuestion(q['id'] as String, true)),
        _quickReplyChip('No', () => _answerQuestion(q['id'] as String, false)),
      ],
    );
  }

  void _answerQuestion(String questionId, bool answer) {
    _userSay(answer ? 'Yes' : 'No');
    _answers[questionId] = answer;
    _questionIndex++;
    _askNextQuestion();
  }

    void _handleFreeText(String text) {
    _userSay(text);
    _controller.clear();

    // First message from user -> bot greets
    if (_stage == ChatStage.notStarted) {
      setState(() => _stage = ChatStage.greeted);
      Future.delayed(const Duration(milliseconds: 500), () {
        _botSay('Hello! I am MechNow AI Assistant. How can I help you today? 🚗🔧');
      });
      return;
    }

    // Second message from user -> bot asks for bike photo
    if (_stage == ChatStage.greeted) {
      setState(() => _stage = ChatStage.awaitingBikePhoto);
      Future.delayed(const Duration(milliseconds: 500), () {
        _botSay('First of all, please upload a photo of your bike so I can identify the bike type.');
      });
      return;
    }

    if (_stage == ChatStage.askingSymptoms && _selectedIssueKey == 'other') {
      _requestGeminiFreeform(text);
      return;
    }

    _botSay('Please use the buttons above to answer, or tell me your vehicle issue.');
  }

  void _computeDiagnosis() {
    final issueBlock = _issuesData?[_selectedIssueKey] as Map<String, dynamic>?;
    final causes = (issueBlock?['causes'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

    final trueTags = _answers.entries.where((e) => e.value).map((e) => e.key).toSet();

    Map<String, dynamic>? best;
    int bestScore = -1;
    for (final cause in causes) {
      final tags = (cause['symptom_tags'] as List<dynamic>? ?? []).cast<String>();
      final bodyTypes = (cause['body_types'] as List<dynamic>? ?? []).cast<String>();
      if (_detectedBodyType != null && bodyTypes.isNotEmpty && !bodyTypes.contains(_detectedBodyType)) {
        continue;
      }
      final score = tags.where(trueTags.contains).length;
      if (score > bestScore) {
        bestScore = score;
        best = cause;
      }
    }

    setState(() {
      _matchedCause = best;
      _stage = ChatStage.showingSolution;
    });

    if (best == null) {
      _botSay(
        "I couldn't pinpoint the exact cause from your answers. It's best to have a mechanic take a look.",
        quickReplies: [_quickReplyChip('🔧 Contact Mechanic', _goToMechanic)],
      );
      return;
    }

    _requestGeminiSolution(best);
  }

  Future<void> _requestGeminiSolution(Map<String, dynamic> cause) async {
    setState(() => _isBusy = true);
    _botSay('Preparing the best solution for you...');
    try {
      final uri = Uri.parse('$kBaseUrl/api/chat/diagnose');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'issueType': _selectedIssueKey,
              'bodyType': _detectedBodyType,
              'causeId': cause['id'],
              'causeName': cause['name'],
              'answers': _answers,
            }),
          )
          .timeout(const Duration(seconds: 20));
      setState(() => _isBusy = false);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _showSolution(data['solutionText'] as String, cause);
      } else {
        _showSolution(_localSolutionText(cause), cause);
      }
    } catch (e) {
      setState(() => _isBusy = false);
      _showSolution(_localSolutionText(cause), cause);
    }
  }

  Future<void> _requestGeminiFreeform(String description) async {
    setState(() => _isBusy = true);
    _botSay('Let me check that for you...');
    try {
      final uri = Uri.parse('$kBaseUrl/api/chat/diagnose');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'issueType': 'other',
              'bodyType': _detectedBodyType,
              'freeText': description,
            }),
          )
          .timeout(const Duration(seconds: 20));
      setState(() => _isBusy = false);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _stage = ChatStage.showingSolution);
        _botSay(data['solutionText'] as String,
            quickReplies: [_quickReplyChip('🔧 Contact Mechanic', _goToMechanic)]);
      } else {
        _botSay("I noted your issue. Let's connect you with a mechanic who can take a closer look.",
            quickReplies: [_quickReplyChip('🔧 Contact Mechanic', _goToMechanic)]);
      }
    } catch (e) {
      setState(() => _isBusy = false);
      _botSay("I noted your issue. Let's connect you with a mechanic who can take a closer look.",
          quickReplies: [_quickReplyChip('🔧 Contact Mechanic', _goToMechanic)]);
    }
  }

  String _localSolutionText(Map<String, dynamic> cause) {
    final buffer = StringBuffer();
    buffer.writeln('🔍 Likely cause: ${cause['name']}');
    if (cause['diy_possible'] == true && cause['diy_note'] != null) {
      buffer.writeln('\n💡 You can try: ${cause['diy_note']}');
    }
    if (cause['safety_note'] != null) {
      buffer.writeln('\n⚠️ ${cause['safety_note']}');
    }
    if (cause['avg_cost_lkr'] != null) {
      buffer.writeln('\n💰 Estimated cost: Rs. ${cause['avg_cost_lkr']}');
    }
    return buffer.toString().trim();
  }

  void _showSolution(String text, Map<String, dynamic> cause) {
    setState(() => _stage = ChatStage.showingSolution);
    _botSay(text, quickReplies: [_quickReplyChip('🔧 Contact Mechanic', _goToMechanic)]);
  }

  void _goToMechanic() {
    Navigator.pop(context, {
      'issueType': _selectedIssueKey,
      'bodyType': _detectedBodyType,
      'mechanicSpecialty': _matchedCause?['mechanic_specialty'],
      'causeName': _matchedCause?['name'],
    });
  }

  Widget _quickReplyChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: _isBusy ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 8, right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kPrimary),
        ),
        child: Text(label, style: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            CircleAvatar(backgroundColor: Colors.white, radius: 16, child: Icon(Icons.smart_toy, color: kPrimary, size: 18)),
            SizedBox(width: 8),
            Text('MechNow AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _messageBubble(_messages[index]),
            ),
          ),
          if (_isBusy) const LinearProgressIndicator(color: kPrimary),
          if (_detectedBodyType == null) _imagePickerBar(),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _imagePickerBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.orange[50],
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isBusy ? null : () => _pickBikeImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt, color: kPrimary),
              label: const Text('Camera', style: TextStyle(color: kPrimary)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: kPrimary)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isBusy ? null : () => _pickBikeImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library, color: kPrimary),
              label: const Text('Gallery', style: TextStyle(color: kPrimary)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: kPrimary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (text) {
                if (text.trim().isEmpty) return;
                _handleFreeText(text.trim());
              },
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              final text = _controller.text.trim();
              if (text.isEmpty) return;
              _handleFreeText(text);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageBubble(Map<String, dynamic> message) {
    final bool isBot = message['isBot'] as bool;
    final List<Widget>? chips = message['quickReplies'] as List<Widget>?;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isBot) ...[
                const CircleAvatar(backgroundColor: kPrimary, radius: 16, child: Icon(Icons.smart_toy, color: Colors.white, size: 16)),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isBot ? Colors.grey[100] : kPrimary,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isBot ? 0 : 16),
                      bottomRight: Radius.circular(isBot ? 16 : 0),
                    ),
                  ),
                  child: Text(message['text'] as String, style: TextStyle(color: isBot ? Colors.black87 : Colors.white, fontSize: 14)),
                ),
              ),
            ],
          ),
          if (chips != null && chips.isNotEmpty)
            Padding(padding: const EdgeInsets.only(left: 40, top: 4), child: Wrap(children: chips)),
        ],
      ),
    );
  }
}