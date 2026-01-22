import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

/// Payment Method Model
class PaymentMethod {
  final String id;
  final String type; // 'card', 'wallet', 'cash'
  final String? last4;
  final String? brand;
  final bool isDefault;

  const PaymentMethod({
    required this.id,
    required this.type,
    this.last4,
    this.brand,
    this.isDefault = false,
  });
}

/// Payment Methods Screen
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<PaymentMethod> _methods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() => _isLoading = true);
    
    // Sample data
    await Future.delayed(const Duration(milliseconds: 500));
    
    _methods = [
      const PaymentMethod(
        id: '1',
        type: 'card',
        brand: 'Visa',
        last4: '4242',
        isDefault: true,
      ),
      const PaymentMethod(
        id: '2',
        type: 'card',
        brand: 'Mastercard',
        last4: '8888',
      ),
      const PaymentMethod(
        id: '3',
        type: 'wallet',
      ),
      const PaymentMethod(
        id: '4',
        type: 'cash',
      ),
    ];

    setState(() => _isLoading = false);
  }

  void _setDefault(PaymentMethod method) {
    setState(() {
      _methods = _methods.map((m) {
        return PaymentMethod(
          id: m.id,
          type: m.type,
          last4: m.last4,
          brand: m.brand,
          isDefault: m.id == method.id,
        );
      }).toList();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحديث طريقة الدفع الافتراضية'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteMethod(PaymentMethod method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف طريقة الدفع'),
        content: const Text('هل أنت متأكد من حذف طريقة الدفع هذه؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _methods.removeWhere((m) => m.id == method.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حذف طريقة الدفع'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addCard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddCardModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        appBar: AppBar(
          title: const Text('طرق الدفع'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _methods.length + 1,
                itemBuilder: (context, index) {
                  if (index == _methods.length) {
                    return _buildAddCardButton(isDark);
                  }
                  
                  final method = _methods[index];
                  return _buildPaymentMethodCard(method, isDark, index);
                },
              ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method, bool isDark, int index) {
    IconData icon;
    String title;
    String subtitle;

    switch (method.type) {
      case 'card':
        icon = method.brand == 'Visa' ? Icons.payment : Icons.credit_card;
        title = '${method.brand} •••• ${method.last4}';
        subtitle = 'بطاقة ائتمان';
        break;
      case 'wallet':
        icon = Icons.account_balance_wallet;
        title = 'محفظة Fixsy';
        subtitle = 'رصيد: 150 ج.م';
        break;
      case 'cash':
        icon = Icons.money;
        title = 'الدفع نقداً';
        subtitle = 'عند التسليم';
        break;
      default:
        icon = Icons.payment;
        title = 'طريقة دفع';
        subtitle = '';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: method.isDefault
              ? AppTheme.primaryColor
              : (isDark ? Colors.white12 : Colors.grey.shade200),
          width: method.isDefault ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: method.type == 'card'
                ? Colors.blue.withOpacity(0.1)
                : method.type == 'wallet'
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: method.type == 'card'
                ? Colors.blue
                : method.type == 'wallet'
                    ? Colors.green
                    : Colors.orange,
          ),
        ),
        title: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            if (method.isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'افتراضي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.black54,
            fontSize: 13,
          ),
        ),
        trailing: method.type != 'cash' && method.type != 'wallet'
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'default') {
                    _setDefault(method);
                  } else if (value == 'delete') {
                    _deleteMethod(method);
                  }
                },
                itemBuilder: (context) => [
                  if (!method.isDefault)
                    const PopupMenuItem(
                      value: 'default',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline),
                          SizedBox(width: 8),
                          Text('تعيين كافتراضي'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Text('حذف', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              )
            : null,
        onTap: () {
          if (!method.isDefault) {
            _setDefault(method);
          }
        },
      ),
    ).animate().fadeIn(delay: (100 * index).ms);
  }

  Widget _buildAddCardButton(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: OutlinedButton.icon(
        onPressed: _addCard,
        icon: const Icon(Icons.add),
        label: const Text('إضافة بطاقة جديدة'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          side: BorderSide(
            color: AppTheme.primaryColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

/// Add Card Modal
class AddCardModal extends StatefulWidget {
  const AddCardModal({super.key});

  @override
  State<AddCardModal> createState() => _AddCardModalState();
}

class _AddCardModalState extends State<AddCardModal> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _saveCard = true;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Add card via payment gateway
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إضافة البطاقة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ، حاول مرة أخرى'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkBackground : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'إضافة بطاقة جديدة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              // Card Number
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'رقم البطاقة',
                  prefixIcon: const Icon(Icons.credit_card),
                  filled: true,
                  fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) => v!.length < 16 ? 'رقم غير صحيح' : null,
              ),
              const SizedBox(height: 16),

              // Expiry & CVV
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        labelText: 'MM/YY',
                        filled: true,
                        fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        filled: true,
                        fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) => v!.length < 3 ? 'CVV غير صحيح' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Name on Card
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'الاسم على البطاقة',
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),

              // Save Card Switch
              SwitchListTile(
                title: Text(
                  'حفظ البطاقة للمرات القادمة',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                value: _saveCard,
                onChanged: (v) => setState(() => _saveCard = v),
                activeColor: AppTheme.primaryColor,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 24),

              // Add Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('إضافة البطاقة'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
