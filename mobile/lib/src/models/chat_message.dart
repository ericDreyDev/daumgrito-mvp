class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.senderName,
    required this.sentAt,
    required this.isMine,
  });

  final String id;
  final String text;
  final String senderName;
  final DateTime sentAt;
  final bool isMine;
}
