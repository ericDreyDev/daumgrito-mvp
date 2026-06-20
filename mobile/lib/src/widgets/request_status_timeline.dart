import 'package:flutter/material.dart';

class RequestStatusTimeline extends StatelessWidget {
  const RequestStatusTimeline({
    required this.status,
    this.compact = false,
    super.key,
  });

  final String status;
  final bool compact;

  static const _statuses = [
    'Aguardando aceite',
    'Aceito',
    'Em andamento',
    'Finalizado',
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _normalizedIndex(status);
    final canceled = _normalize(status) == 'cancelado' || _normalize(status) == 'recusado';

    return Column(
      children: [
        Row(
          children: List.generate(_statuses.length, (index) {
            final done = !canceled && index <= currentIndex;
            return Expanded(
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: compact ? 18 : 26,
                    width: compact ? 18 : 26,
                    decoration: BoxDecoration(
                      color: done ? Theme.of(context).colorScheme.primary : const Color(0xFFE5EAF1),
                      shape: BoxShape.circle,
                    ),
                    child: done ? Icon(Icons.check_rounded, size: compact ? 13 : 17, color: Colors.white) : null,
                  ),
                  if (index < _statuses.length - 1)
                    Expanded(
                      child: Container(
                        height: 3,
                        color: done && index < currentIndex ? Theme.of(context).colorScheme.primary : const Color(0xFFE5EAF1),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        if (!compact) ...[
          const SizedBox(height: 10),
          Row(
            children: _statuses.map((item) {
              return Expanded(
                child: Text(
                  item,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  int _normalizedIndex(String value) {
    final normalized = _normalize(value);
    if (normalized == 'solicitado' || normalized == 'aguardando aceite') return 0;
    if (normalized == 'agendado' || normalized == 'aceito' || normalized == 'em negociacao') return 1;
    if (normalized == 'em andamento') return 2;
    if (normalized == 'concluido' || normalized == 'finalizado') return 3;
    return 0;
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('ç', 'c')
        .replaceAll('ã', 'a')
        .replaceAll('õ', 'o')
        .replaceAll('í', 'i')
        .replaceAll('ú', 'u')
        .replaceAll('Ã§', 'c')
        .replaceAll('Ã£', 'a')
        .replaceAll('Ãµ', 'o')
        .replaceAll('Ã­', 'i')
        .replaceAll('Ãº', 'u')
        .replaceAll('ÃƒÂ§', 'c')
        .replaceAll('ÃƒÂ£', 'a')
        .replaceAll('ÃƒÂ­', 'i')
        .replaceAll('ÃƒÂº', 'u');
  }
}
