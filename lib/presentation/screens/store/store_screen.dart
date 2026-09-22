import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final List<String> _categories = ['الكل', 'سباكة', 'كهرباء', 'تكييف', 'أدوات'];
  String _selectedCategory = 'الكل';
  String _searchQuery = '';
  final Map<String, int> _cart = {};

  final List<Map<String, dynamic>> _products = [
    {
      'id': '1',
      'name': 'صنبور خلاط إيطالي فاخر',
      'price': 1500,
      'category': 'سباكة',
      'image': Icons.water_drop,
      'color': Colors.blue,
      'rating': 4.9,
    },
    {
      'id': '2',
      'name': 'مفتاح كهرباء ذكي Wi-Fi',
      'price': 250,
      'category': 'كهرباء',
      'image': Icons.lightbulb,
      'color': Colors.amber,
      'rating': 4.8,
    },
    {
      'id': '3',
      'name': 'فلتر تكييف أصلي عالي الكفاءة',
      'price': 300,
      'category': 'تكييف',
      'image': Icons.ac_unit,
      'color': Colors.cyan,
      'rating': 4.7,
    },
    {
      'id': '4',
      'name': 'طقم مفكات احترافي 24 قطعة',
      'price': 450,
      'category': 'أدوات',
      'image': Icons.build,
      'color': Colors.blueGrey,
      'rating': 4.9,
    },
    {
      'id': '5',
      'name': 'لمبة LED ذكية موفرة للطاقة',
      'price': 50,
      'category': 'كهرباء',
      'image': Icons.light_mode,
      'color': Colors.orange,
      'rating': 4.6,
    },
    {
      'id': '6',
      'name': 'محبس مياه نحاس 1 بوصة أصلي',
      'price': 180,
      'category': 'سباكة',
      'image': Icons.plumbing,
      'color': Colors.indigo,
      'rating': 4.8,
    },
  ];

  int get _totalCartItems => _cart.values.fold(0, (sum, count) => sum + count);

  double get _cartTotal {
    double total = 0;
    _cart.forEach((id, qty) {
      final product = _products.firstWhere((p) => p['id'] == id, orElse: () => {});
      if (product.isNotEmpty) {
        total += (product['price'] as num) * qty;
      }
    });
    return total;
  }

  void _addToCart(String productId) {
    setState(() {
      _cart[productId] = (_cart[productId] ?? 0) + 1;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('تمت إضافة المنتج إلى سلة المشتريات'),
          ],
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.successColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _removeFromCart(String productId) {
    setState(() {
      if (_cart.containsKey(productId)) {
        if (_cart[productId]! > 1) {
          _cart[productId] = _cart[productId]! - 1;
        } else {
          _cart.remove(productId);
        }
      }
    });
  }

  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final total = _cartTotal;
          final deliveryFee = total > 500 || total == 0 ? 0.0 : 30.0;
          final grandTotal = total + deliveryFee;

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'سلة المشتريات (${_totalCartItems})',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (_cart.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() => _cart.clear());
                          setModalState(() {});
                          Navigator.pop(context);
                        },
                        child: const Text('إفراغ السلة', style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
                const Divider(height: 20),
                Expanded(
                  child: _cart.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.remove_shopping_cart_outlined, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                'سلة المشتريات فارغة',
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'تصفح قطع الغيار واضغط على إضافة للسلة',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          children: _cart.entries.map((entry) {
                            final product = _products.firstWhere((p) => p['id'] == entry.key);
                            final qty = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: (product['color'] as Color).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(product['image'] as IconData, color: product['color'] as Color),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        const SizedBox(height: 4),
                                        Text('${product['price']} ج.م', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, size: 22, color: Colors.grey),
                                        onPressed: () {
                                          setState(() => _removeFromCart(product['id']));
                                          setModalState(() {});
                                        },
                                      ),
                                      Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, size: 22, color: AppTheme.primaryColor),
                                        onPressed: () {
                                          setState(() => _addToCart(product['id']));
                                          setModalState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
                if (_cart.isNotEmpty) ...[
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('المجموع الفرعي:', style: TextStyle(color: Colors.grey)),
                      Text('${total.toStringAsFixed(0)} ج.م', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('خدمة التوصيل السريع:', style: TextStyle(color: Colors.grey)),
                      Text(
                        deliveryFee == 0 ? 'مجاني (عرض خاص)' : '${deliveryFee.toStringAsFixed(0)} ج.م',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: deliveryFee == 0 ? Colors.green : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الإجمالي المطلوب:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        '${grandTotal.toStringAsFixed(0)} ج.م',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() => _cart.clear());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🎉 تم استلام طلبك بنجاح! سيصلك مندوبنا خلال ساعتين.'),
                            backgroundColor: AppTheme.successColor,
                            duration: Duration(seconds: 4),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('تأكيد الطلب والدفع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var filteredProducts = _products.where((p) {
      final matchesCategory = _selectedCategory == 'الكل' || p['category'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty || p['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('متجر Fixsy لقطع الغيار'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                tooltip: 'سلة المشتريات',
                onPressed: _showCartSheet,
              ),
              if (_totalCartItems > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Center(
                      child: Text(
                        '$_totalCartItems',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.08),
                  AppTheme.primaryColor.withValues(alpha: 0.02),
                ],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'قطع غيار أصلية 100%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ضمان استبدال حقيقي وتوصيل سريع مع الفني أو لباب منزلك',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.storefront, size: 36, color: AppTheme.primaryColor),
                ),
              ],
            ),
          ).animate().fadeIn(),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن قطعة غيار أو أداة...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.18),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                );
              }).toList(),
            ),
          ),

          // Products Grid
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'لا توجد منتجات مطابقة للبحث',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
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
    final inCartCount = _cart[product['id']] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: (product['color'] as Color).withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Icon(
                    product['image'] as IconData,
                    size: 54,
                    color: product['color'] as Color,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          '${product['rating']}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${product['price']} ج.م',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (inCartCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '× $inCartCount',
                          style: const TextStyle(color: AppTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _addToCart(product['id']),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      backgroundColor: inCartCount > 0 ? AppTheme.primaryColor : Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      inCartCount > 0 ? 'إضافة المزيد' : 'إضافة للسلة',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 40).ms).slideY(begin: 0.1, end: 0);
  }
}
