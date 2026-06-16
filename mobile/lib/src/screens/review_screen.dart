import 'package:flutter/material.dart';

import '../models/service_request.dart';
import '../services/api_client.dart';
import '../services/review_service.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({
    required this.apiClient,
    required this.request,
    super.key,
  });

  final ApiClient apiClient;
  final ServiceRequest request;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _commentController = TextEditingController();
  int _rating = 5;
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await ReviewService(widget.apiClient).create(
        providerId: widget.request.providerId,
        serviceRequestId: widget.request.id,
        rating: _rating,
        comment: _commentController.text.trim(),
      );

      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.star_rounded, size: 54, color: Color(0xFFF59E0B)),
                const SizedBox(height: 12),
                Text('Avaliação enviada', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text('Sua opinião ajuda outros clientes a escolherem melhor.', textAlign: TextAlign.center),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Concluir'),
                ),
              ],
            ),
          );
        },
      );
    } catch (_) {
      setState(() => _error = 'Não foi possível enviar sua avaliação agora.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avaliar profissional')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  CircleAvatar(radius: 32, child: Text(widget.request.provider.name.characters.first.toUpperCase())),
                  const SizedBox(height: 10),
                  Text(widget.request.provider.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(widget.request.service),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Como foi o atendimento?', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final star = index + 1;
                      return IconButton(
                        onPressed: () => setState(() => _rating = star),
                        icon: Icon(
                          star <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                          size: 36,
                          color: const Color(0xFFF59E0B),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _commentController,
                    minLines: 4,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Comentário',
                      hintText: 'Conte como foi sua experiência',
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w700)),
                  ],
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _submit,
                    icon: const Icon(Icons.send_rounded),
                    label: Text(_isSaving ? 'Enviando...' : 'Enviar avaliação'),
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
