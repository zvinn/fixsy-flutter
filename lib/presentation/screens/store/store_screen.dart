import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/common/enhanced_widgets.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final List<String> _categories = ['الكل', 'سباكة', 'كهرباء', 'تكييف', 'أدوات'];
  String _selectedCategory = 'الكل';
  final Map<String, int> _cart = {};

  final List<Map<String, dynamic>> _products = [
    {
      'id': '1',
      'name': 'صنبور خلاط إيطالي',
      'price': 1500,
      'category': 'سباكة',
      'image': Icons.water_drop,
      'color': Colors.blue,
    },
    {
      'id': '2',
      'name': 'مفتاح كهرباء ذكي',
      'price': 250,
      'category': 'كهرباء',
      'image': Icons.lightbulb,
      'color': Colors.amber,
    },
    {
      'id': '3',
      'name': 'فلتر تكييف أصلي',
      'price': 300,
      'category': 'تكييف',
      'image': Icons.ac_unit,
      'color': Colors.cyan,
    },
    {
      'id': '4',
      'name': 'طقم مفكات احترافي',
      'price': 450,
      'category': 'أدوات',
      'image': Icons.build,
      'color': Colors.grey,
    },
     {
      'id': '5',
      'name': 'لمبة LED موفرة',
      'price': 50,
      'category': 'كهرباء',
      'image': Icons.light,
      'color': Colors.amberAccent,
    },
  ];

  void _addToCart(String productId) {
    setState(() {
      _cart[productId] = (_cart[productId] ?? 0) + 1;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تمت الإضافة للسلة'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var filteredProducts = _selectedCategory == 'الكل'
        ? _products
        : _products.where((p) => p['category'] == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('متجر Fixsy'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  // TODO: Show Cart Sheet
                },
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_cart.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor.withOpacity(0.05),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'قطع غيار أصلية',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'توصيل سريع وضمان حقيقي',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.storefront, size: 60, color: AppTheme.primaryColor),
              ],
            ),
          ).animate().fadeIn(),

          // Categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                    },
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Products Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return _buildProductCard(context, product, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: (product['color'] as Color).withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Icon(
                product['image'] as IconData,
                size: 60,
                color: product['color'] as Color,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${product['price']} ج.م',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _addToCart(product['id']),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: const Text('أضف صنبور'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
  }
}
