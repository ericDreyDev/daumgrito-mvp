class ServiceCategory {
  const ServiceCategory({
    required this.name,
    required this.icon,
  });

  final String name;
  final String icon;
}

const serviceCategories = [
  ServiceCategory(name: 'Faxineiro(a)', icon: '🧹'),
  ServiceCategory(name: 'Encanador(a)', icon: '🔧'),
  ServiceCategory(name: 'Eletricista', icon: '💡'),
  ServiceCategory(name: 'Montador de móveis', icon: '🪑'),
  ServiceCategory(name: 'Manutenção básica', icon: '🧰'),
  ServiceCategory(name: 'Jardineiro', icon: '🌱'),
];
