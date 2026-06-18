import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../models/provider.dart';
import '../services/chat_demo_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    required this.provider,
    super.key,
  });

  final ProviderProfile provider;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatDemoService _chatService;
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chatService = ChatDemoService(widget.provider);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chatService.sendAsMe(text);
      _messageController.clear();
    });

    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(_chatService.addDemoReply);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
                child:
                    Text(widget.provider.name.substring(0, 1).toUpperCase())),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.provider.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w900)),
                  const Text('Chat demonstrativo',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: false,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: _chatService.messages.length,
              itemBuilder: (context, index) {
                return _MessageBubble(message: _chatService.messages[index]);
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE5EAF1))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Digite uma mensagem',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 1,
                      maxLines: 4,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send_rounded),
                    tooltip: 'Enviar',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = message.isMine ? colors.primary : Colors.white;
    final foreground =
        message.isMine ? colors.onPrimary : const Color(0xFF10233F);

    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isMine ? 16 : 4),
            bottomRight: Radius.circular(message.isMine ? 4 : 16),
          ),
          border: message.isMine
              ? null
              : Border.all(color: const Color(0xFFE5EAF1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.senderName,
                style: TextStyle(
                    color: foreground.withValues(alpha: 0.78),
                    fontSize: 12,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(message.text,
                style: TextStyle(color: foreground, fontSize: 15)),
            const SizedBox(height: 5),
            Text(_formatTime(message.sentAt),
                style: TextStyle(
                    color: foreground.withValues(alpha: 0.7), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
