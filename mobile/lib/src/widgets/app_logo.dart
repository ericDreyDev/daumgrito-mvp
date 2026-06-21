import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    this.compact = false,
    this.hero = false,
    super.key,
  });

  final bool compact;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    if (hero) {
      return Center(
        child: Image.asset(
          'assets/brand/daumgrito-logo.png',
          height: 178,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: compact ? 42 : 48,
          width: compact ? 42 : 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE5F1FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.campaign_rounded, color: Color(0xFFFF7A00)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dá um grito!',
              style: TextStyle(
                  fontSize: compact ? 19 : 22, fontWeight: FontWeight.w900),
            ),
            if (!compact) const Text('Serviços perto de você'),
          ],
        ),
      ],
    );
  }
}
