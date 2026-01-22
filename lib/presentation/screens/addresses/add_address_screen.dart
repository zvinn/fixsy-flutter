import 'package:flutter/material.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة عنوان جديد'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'اسم العنوان (مثال: المنزل، العمل)',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'مطلوب';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'المدينة / المنطقة',
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'مطلوب';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(
                  labelText: 'اسم الشارع / تفاصيل العنوان',
                  prefixIcon: Icon(Icons.map_outlined),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'مطلوب';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAddress,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('حفظ العنوان', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ العنوان بنجاح')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    super.dispose();
  }
}
