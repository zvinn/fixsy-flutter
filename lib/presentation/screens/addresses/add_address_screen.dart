import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/address_model.dart';
import '../../providers/address_provider.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key, this.addressToEdit});

  final AddressModel? addressToEdit;

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _cityController;
  late final TextEditingController _streetController;
  late final TextEditingController _buildingController;
  late final TextEditingController _floorController;
  late final TextEditingController _apartmentController;
  late final TextEditingController _notesController;
  
  bool _isDefault = false;
  bool _isLoading = false;

  final List<String> _quickLabels = ['المنزل 🏠', 'العمل 🏢', 'شقة الوالدة 👵', 'أخرى 📍'];

  @override
  void initState() {
    super.initState();
    final edit = widget.addressToEdit;
    _labelController = TextEditingController(text: edit?.label ?? 'المنزل');
    _cityController = TextEditingController(text: edit?.city ?? 'القاهرة');
    _streetController = TextEditingController(text: edit?.street ?? '');
    _buildingController = TextEditingController(text: edit?.building ?? '');
    _floorController = TextEditingController(text: edit?.floor ?? '');
    _apartmentController = TextEditingController(text: edit?.apartment ?? '');
    _notesController = TextEditingController(text: edit?.notes ?? '');
    _isDefault = edit?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _apartmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<AddressProvider?>(context, listen: false);
      final isEditing = widget.addressToEdit != null;

      if (isEditing) {
        final updatedAddress = widget.addressToEdit!.copyWith(
          label: _labelController.text.trim(),
          city: _cityController.text.trim(),
          street: _streetController.text.trim(),
          building: _buildingController.text.trim(),
          floor: _floorController.text.trim(),
          apartment: _apartmentController.text.trim(),
          notes: _notesController.text.trim(),
          isDefault: _isDefault,
        );

        if (provider != null) {
          await provider.updateAddress(updatedAddress);
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث العنوان بنجاح ✅'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final newAddress = AddressModel(
          id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
          label: _labelController.text.trim(),
          city: _cityController.text.trim(),
          street: _streetController.text.trim(),
          building: _buildingController.text.trim(),
          floor: _floorController.text.trim(),
          apartment: _apartmentController.text.trim(),
          notes: _notesController.text.trim(),
          isDefault: _isDefault,
          createdAt: DateTime.now(),
        );

        if (provider != null) {
          await provider.addAddress(newAddress);
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت إضافة العنوان الجديد بنجاح ✅'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء حفظ العنوان: $e')),
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
    final isEditing = widget.addressToEdit != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(isEditing ? 'تعديل العنوان' : 'إضافة عنوان جديد'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'نوع العنوان',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _quickLabels.map((l) {
                    final cleanLabel = l.split(' ').first;
                    final isSelected = _labelController.text == cleanLabel;
                    return ChoiceChip(
                      label: Text(l),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) {
                          setState(() => _labelController.text = cleanLabel);
                        }
                      },
                      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: isSelected ? AppTheme.primaryColor : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _labelController,
                  decoration: InputDecoration(
                    labelText: 'اسم العنوان المخصص',
                    prefixIcon: const Icon(Icons.label_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'مطلوب' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'المدينة / المحافظة',
                    prefixIcon: const Icon(Icons.location_city_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'مطلوب' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _streetController,
                  decoration: InputDecoration(
                    labelText: 'اسم الشارع والمنطقة بالتفصيل',
                    prefixIcon: const Icon(Icons.edit_road_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'يرجى كتابة تفاصيل الشارع' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _buildingController,
                        decoration: InputDecoration(
                          labelText: 'رقم العمارة',
                          prefixIcon: const Icon(Icons.apartment_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _floorController,
                        decoration: InputDecoration(
                          labelText: 'الدور',
                          prefixIcon: const Icon(Icons.stairs_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _apartmentController,
                        decoration: InputDecoration(
                          labelText: 'رقم الشقة',
                          prefixIcon: const Icon(Icons.door_front_door_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'علامات مميزة أو ملاحظات للوصول',
                    hintText: 'مثال: بجوار مسجد النور، أمام سوبرماركت سعودي...',
                    prefixIcon: const Icon(Icons.note_alt_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('تعيين كعنوان رئيسي افتراضي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('سيتم اختياره تلقائياً عند طلب أي خدمة جديدة', style: TextStyle(fontSize: 12)),
                    value: _isDefault,
                    activeThumbColor: AppTheme.primaryColor,
                    onChanged: (val) => setState(() => _isDefault = val),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveAddress,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.save_rounded, color: Colors.white),
                    label: Text(
                      _isLoading ? 'جاري الحفظ...' : (isEditing ? 'حفظ التعديلات' : 'حفظ العنوان الآن'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
