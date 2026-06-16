import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    this.compact = false,
    super.key,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: compact ? 42 : 48,
          width: compact ? 42 : 48,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE8CC),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.campaign_rounded, color: Color(0xFFB45309)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dá um grito!',
              style: TextStyle(fontSize: compact ? 19 : 22, fontWeight: FontWeight.w900),
            ),
            if (!compact) const Text('Serviços perto de você'),
          ],
        ),
      ],
    );
  }
}
