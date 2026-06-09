import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE8CC),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.campaign_rounded, color: Color(0xFFB45309)),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dá um grito!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            Text('Serviços perto de você'),
          ],
        ),
      ],
    );
  }
}
