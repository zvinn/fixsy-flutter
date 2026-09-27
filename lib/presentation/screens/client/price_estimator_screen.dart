import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class PriceEstimatorScreen extends StatefulWidget {
  const PriceEstimatorScreen({super.key});

  @override
  State<PriceEstimatorScreen> createState() => _PriceEstimatorScreenState();
}

class _PriceEstimatorScreenState extends State<PriceEstimatorScreen> {
  int _selectedCategoryIndex = 0;
  int _selectedServiceIndex = 0;
  double _quantity = 1;
  bool _includeMaterials = false;
  bool _urgent = false;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'تكييف', 'icon': Icons.ac_unit, 'basePrice': 150},
    {'name': 'سباكة', 'icon': Icons.plumbing, 'basePrice': 100},
    {'name': 'كهرباء', 'icon': Icons.electrical_services, 'basePrice': 120},
    {'name': 'نقاشة', 'icon': Icons.format_paint, 'basePrice': 200},
  ];

  final Map<int, List<Map<String, dynamic>>> _services = {
    0: [
      {'name': 'صيانة دورية', 'multiplier': 1.0},
      {'name': 'تركيب تكييف جديد', 'multiplier': 2.5},
      {'name': 'شحن فريون', 'multiplier': 1.5},
    ],
    1: [
      {'name': 'تصليح تسريب', 'multiplier': 1.0},
      {'name': 'تأسيس حمام', 'multiplier': 4.0},
      {'name': 'تغيير خلاط', 'multiplier': 0.8},
    ],
    2: [
      {'name': 'تصليح قفلة', 'multiplier': 1.2},
      {'name': 'تأسيس شقة', 'multiplier': 8.0},
      {'name': 'تركيب نجف', 'multiplier': 0.5},
    ],
    3: [
      {'name': 'دهان غرفة', 'multiplier': 1.0},
      {'name': 'تشطيب شقة', 'multiplier': 10.0},
    ],
  };

  double get _estimatedMinPrice {
    final base = _categories[_selectedCategoryIndex]['basePrice'] as int;
    final multiplier = _services[_selectedCategoryIndex]![_selectedServiceIndex]['multiplier'] as double;
    
    double total = base * multiplier * _quantity;
    if (_includeMaterials) total += (total * 0.4); // Add 40% for materials avg
    if (_urgent) total += 50; // Urgent fee
    
    return total;
  }

  double get _estimatedMaxPrice {
    return _estimatedMinPrice * 1.3; // +30% for max range
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        appBar: AppBar(
          title: const Text('حاسبة التكلفة التقديرية'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.white : Colors.black,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 1. Categories
                  const Text('اختر القسم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedCategoryIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                              _selectedServiceIndex = 0; // Reset service
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 85,
                            margin: const EdgeInsets.only(left: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryColor : (isDark ? AppTheme.darkCardColor : Colors.white),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryColor : (isDark ? Colors.white12 : Colors.grey.shade300),
                              ),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _categories[index]['icon'] as IconData,
                                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _categories[index]['name'] as String,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ).animate().fadeIn().slideX(),

                  const SizedBox(height: 24),
                  
                  // 2. Services
                  const Text('نوع الخدمة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      _services[_selectedCategoryIndex]!.length,
                      (index) {
                        final isSelected = _selectedServiceIndex == index;
                        return ChoiceChip(
                          label: Text(_services[_selectedCategoryIndex]![index]['name'] as String),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedServiceIndex = index);
                          },
                          selectedColor: AppTheme.primaryColor.withOpacity(0.15),
                          labelStyle: TextStyle(
                            color: isSelected ? AppTheme.primaryColor : (isDark ? Colors.white70 : Colors.black54),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppTheme.primaryColor : (isDark ? Colors.white12 : Colors.grey.shade300),
                            ),
                          ),
                          backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
                        );
                      },
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 32),

                  // 3. Quantity Slider
                  Text(
                    'الكمية / عدد الوحدات: ${_quantity.toInt()}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppTheme.primaryColor,
                      inactiveTrackColor: isDark ? Colors.white12 : Colors.grey.shade200,
                      thumbColor: AppTheme.primaryColor,
                      overlayColor: AppTheme.primaryColor.withOpacity(0.2),
                      trackHeight: 8,
                    ),
                    child: Slider(
                      value: _quantity,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: _quantity.toInt().toString(),
                      onChanged: (val) => setState(() => _quantity = val),
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 24),

                  // 4. Toggles (Materials & Urgency)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCardColor : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('شامل قطع الغيار/الخامات', style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: const Text('سيقوم الفني بإحضار الخامات المطلوبة', style: TextStyle(fontSize: 12)),
                          activeColor: AppTheme.primaryColor,
                          value: _includeMaterials,
                          onChanged: (val) => setState(() => _includeMaterials = val),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('زيارة طارئة (الآن)', style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: const Text('يضاف رسوم سرعة استجابة', style: TextStyle(fontSize: 12)),
                          activeColor: Colors.redAccent,
                          value: _urgent,
                          onChanged: (val) => setState(() => _urgent = val),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
            
            // 5. Sticky Bottom Result Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCardColor : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'التكلفة التقديرية:',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        // Animated Price Range
                        Row(
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: _estimatedMinPrice),
                              duration: const Duration(milliseconds: 500),
                              builder: (context, value, child) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                );
                              },
                            ),
                            const Text(' - ', style: TextStyle(fontSize: 20, color: Colors.grey)),
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: _estimatedMaxPrice),
                              duration: const Duration(milliseconds: 500),
                              builder: (context, value, child) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 4),
                            const Text('ج.م', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          // Handle booking logic based on estimate
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('تم تحويل التسعير لشاشة الحجز بنجاح!'),
                              backgroundColor: Colors.green.shade600,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text(
                          'استمر للحجز بهذا التسعير',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
