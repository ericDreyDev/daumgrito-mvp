import 'package:flutter/material.dart';

import '../models/provider.dart';

class ProviderCard extends StatelessWidget {
  const ProviderCard({
    required this.provider,
    required this.onTap,
    super.key,
  });

  final ProviderProfile provider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final rating = provider.averageRating == 0
        ? 'Novo'
        : provider.averageRating.toStringAsFixed(1);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: colors.primaryContainer,
                    foregroundColor: colors.onPrimaryContainer,
                    child: Text(
                      provider.name.isEmpty
                          ? '?'
                          : provider.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(provider.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 16, color: Color(0xFF516070)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${provider.city}, ${provider.neighborhood}',
                                style:
                                    const TextStyle(color: Color(0xFF516070)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7E6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 17, color: Color(0xFFFF7A00)),
                        const SizedBox(width: 3),
                        Text(rating,
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.services.take(3).map((service) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF6FF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(service,
                        style: const TextStyle(
                            color: Color(0xFF1A56DB),
                            fontWeight: FontWeight.w700)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 18, color: colors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(provider.availability ??
                          'Disponibilidade a combinar')),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 15, color: Color(0xFF98A2B3)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
