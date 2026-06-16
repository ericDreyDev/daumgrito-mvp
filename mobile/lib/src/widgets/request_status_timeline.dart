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
    'Solicitado',
    'Em negociação',
    'Agendado',
    'Em andamento',
    'Concluído',
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _normalizedIndex(status);

    return Column(
      children: [
        Row(
          children: List.generate(_statuses.length, (index) {
            final done = index <= currentIndex;
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
                        color: index < currentIndex ? Theme.of(context).colorScheme.primary : const Color(0xFFE5EAF1),
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
    if (value == 'Cancelado') return 0;
    final index = _statuses.indexWhere((item) => _normalize(item) == _normalize(value));
    return index < 0 ? 0 : index;
  }

  String _normalize(String value) {
    return value
        .replaceAll('Ã§', 'ç')
        .replaceAll('Ã­', 'í')
        .replaceAll('Ã£', 'ã')
        .replaceAll('Ã¡', 'á')
        .replaceAll('Ã³', 'ó')
        .replaceAll('Ãº', 'ú');
  }
}
