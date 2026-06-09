import '../models/chat_message.dart';
import '../models/provider.dart';

class ChatDemoService {
  ChatDemoService(this.provider) {
    _messages.addAll([
      ChatMessage(
        id: '1',
        text: 'Olá! Vi seu perfil e queria tirar uma dúvida sobre disponibilidade.',
        senderName: 'Você',
        sentAt: DateTime.now().subtract(const Duration(minutes: 9)),
        isMine: true,
      ),
      ChatMessage(
        id: '2',
        text: 'Claro! Me mande o bairro, o serviço e a melhor data para eu avaliar.',
        senderName: provider.name,
        sentAt: DateTime.now().subtract(const Duration(minutes: 7)),
        isMine: false,
      ),
    ]);
  }

  final ProviderProfile provider;
  final List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  void sendAsMe(String text) {
    _messages.add(
      ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: text,
        senderName: 'Você',
        sentAt: DateTime.now(),
        isMine: true,
      ),
    );
  }

  void addDemoReply() {
    _messages.add(
      ChatMessage(
        id: '${DateTime.now().microsecondsSinceEpoch}-reply',
        text: 'Recebi sua mensagem. Posso te passar uma estimativa e combinar os detalhes por aqui.',
        senderName: provider.name,
        sentAt: DateTime.now().add(const Duration(seconds: 1)),
        isMine: false,
      ),
    );
  }
}
