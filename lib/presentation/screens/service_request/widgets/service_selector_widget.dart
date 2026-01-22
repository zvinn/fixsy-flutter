import 'package:flutter/material.dart';

class ServiceSelectorWidget extends StatelessWidget {
  final String selectedService;
  final Function(String) onServiceSelected;

  const ServiceSelectorWidget({
    super.key,
    required this.selectedService,
    required this.onServiceSelected,
  });

  static const services = [
    {'name': 'سباكة', 'icon': Icons.plumbing, 'color': Colors.blue},
    {'name': 'كهرباء', 'icon': Icons.electrical_services, 'color': Colors.amber},
    {'name': 'نجارة', 'icon': Icons.carpenter, 'color': Colors.brown},
    {'name': 'تكييف', 'icon': Icons.ac_unit, 'color': Colors.cyan},
    {'name': 'دهان', 'icon': Icons.format_paint, 'color': Colors.purple},
    {'name': 'أخرى', 'icon': Icons.home_repair_service, 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر نوع الخدمة المطلوبة:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            final name = service['name'] as String;
            final icon = service['icon'] as IconData;
            final color = service['color'] as Color;
            final isSelected = selectedService == name;

            return InkWell(
              onTap: () => onServiceSelected(name),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 48,
                      color: isSelected ? color : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? color : Colors.grey[700],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
