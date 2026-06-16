import 'package:flutter/material.dart';

class ServiceCategory {
  const ServiceCategory({
    required this.name,
    required this.icon,
  });

  final String name;
  final IconData icon;
}

const serviceCategories = [
  ServiceCategory(name: 'Faxineiro(a)', icon: Icons.cleaning_services_rounded),
  ServiceCategory(name: 'Encanador(a)', icon: Icons.plumbing_rounded),
  ServiceCategory(name: 'Eletricista', icon: Icons.electrical_services_rounded),
  ServiceCategory(name: 'Montador de móveis', icon: Icons.chair_rounded),
  ServiceCategory(name: 'Manutenção básica', icon: Icons.home_repair_service_rounded),
  ServiceCategory(name: 'Jardineiro', icon: Icons.yard_rounded),
];
