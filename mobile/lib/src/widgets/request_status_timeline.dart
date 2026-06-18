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
                      color: done
                          ? Theme.of(context).colorScheme.primary
                          : const Color(0xFFE5EAF1),
                      shape: BoxShape.circle,
                    ),
                    child: done
                        ? Icon(Icons.check_rounded,
                            size: compact ? 13 : 17, color: Colors.white)
                        : null,
                  ),
                  if (index < _statuses.length - 1)
                    Expanded(
                      child: Container(
                        height: 3,
                        color: index < currentIndex
                            ? Theme.of(context).colorScheme.primary
                            : const Color(0xFFE5EAF1),
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
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700),
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
    if (normalized == 'cancelado' || normalized == 'recusado') return 0;
    if (normalized == 'solicitado') return 0;
    if (normalized == 'agendado') return 1;
    if (normalized == 'concluido') return 3;
    final index =
        _statuses.indexWhere((item) => _normalize(item) == normalized);
    return index < 0 ? 0 : index;
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('ç', 'c')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
  }
}
