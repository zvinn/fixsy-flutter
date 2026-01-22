import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../providers/service_request_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../../data/services/coupon_service.dart';
import '../service_request/widgets/service_selector_widget.dart';
import '../service_request/widgets/image_upload_widget.dart';
import 'payment_method_selector.dart';
import 'dart:io';

class BookingModal extends StatefulWidget {
  final String? initialServiceType;
  final VoidCallback? onSubmit;

  const BookingModal({
    super.key,
    this.initialServiceType,
    this.onSubmit,
  });

  @override
  State<BookingModal> createState() => _BookingModalState();
}

class _BookingModalState extends State<BookingModal> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _couponController = TextEditingController();
  final CouponService _couponService = CouponService();
  
  int _currentStep = 0;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  PaymentMethodType _selectedPaymentMethod = PaymentMethodType.cash;
  CouponModel? _appliedCoupon;
  bool _isValidatingCoupon = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialServiceType != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ServiceRequestProvider>().setServiceType(widget.initialServiceType!);
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _errorMessage('Logic error: Step out of bounds');
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;
    
    setState(() => _isValidatingCoupon = true);
    
    final coupon = await _couponService.validateCoupon(code);
    
    setState(() {
      _isValidatingCoupon = false;
      if (coupon != null) {
        _appliedCoupon = coupon;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t('couponApplied')), backgroundColor: AppTheme.successColor),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t('invalidCoupon')), backgroundColor: AppTheme.errorColor),
        );
      }
    });
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    
    final provider = context.read<ServiceRequestProvider>();
    final auth = context.read<AuthProvider>();
    
    if (auth.currentUser == null) {
      _errorMessage(context.t('loginFirst'));
      return;
    }

    try {
      // Add extra data to provider if needed, or pass directly to submitRequest
      // For now we assume provider holds most state, but we might need to extend submitRequest
      // to accept payment method and coupon.
      
      // Simulating passing extra data
      // await provider.submitRequest(
      //   userId: auth.currentUser!.id,
      //   paymentMethod: _selectedPaymentMethod,
      //   couponCode: _appliedCoupon?.code,
      //   scheduledDate: _scheduledDate,
      // );
       
      await provider.submitRequest(auth.currentUser!.id);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t('bookingSuccess')), backgroundColor: AppTheme.successColor),
      );
      
      widget.onSubmit?.call();
      Navigator.pop(context);
    } catch (e) {
      _errorMessage(context.t('bookingFailed'));
    }
  }

  void _errorMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.errorColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container( // Modal bottom sheet content
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    context.t('bookService'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 48), // Balance for close button
              ],
            ),
          ),
          const Divider(height: 1),
          
          Expanded(
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              controlsBuilder: (context, details) => const SizedBox(), // Custom controls
              elevation: 0,
              steps: [
                Step(
                  title: Text(context.t('service')),
                  content: _buildServiceCloud(),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 ? StepState.complete : StepState.editing,
                ),
                Step(
                  title: Text(context.t('details')),
                  content: _buildDetailsForm(),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1 ? StepState.complete : StepState.editing,
                ),
                Step(
                  title: Text(context.t('confirm')),
                  content: _buildConfirmation(),
                  isActive: _currentStep >= 2,
                  state: _currentStep > 2 ? StepState.complete : StepState.editing,
                ),
              ],
            ),
          ),
          
          // Custom Bottom Navigation
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _prevStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(context.t('back')),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _currentStep == 2 
                        ? (context.watch<ServiceRequestProvider>().isSubmitting ? null : _submitBooking) 
                        : _nextStep,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _currentStep == 2 ? AppTheme.successColor : AppTheme.primaryColor,
                    ),
                    child: context.watch<ServiceRequestProvider>().isSubmitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                        : Text(_currentStep == 2 ? context.t('confirmBooking') : context.t('next')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCloud() {
    return Consumer<ServiceRequestProvider>(
      builder: (context, provider, _) {
        return ServiceSelectorWidget(
          selectedService: provider.selectedServiceType,
          onServiceSelected: (service) => provider.setServiceType(service),
        );
      },
    );
  }

  Widget _buildDetailsForm() {
    return Consumer<ServiceRequestProvider>(
      builder: (context, provider, _) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: context.t('describeProblem'),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: provider.setDescription,
                validator: (v) => v?.isEmpty == true ? context.t('dataMissing') : null,
              ),
              const SizedBox(height: 16),
              
              const ImageUploadWidget(
                // We'd need to bind this properly, simplified for now
                images: [], 
                onImagesChanged: null, 
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: context.t('yourAddress'),
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: () {
                      // Implement geolocation
                    },
                  ),
                ),
                onChanged: provider.setAddress,
                validator: (v) => v?.isEmpty == true ? context.t('dataMissing') : null,
              ),
              
              const SizedBox(height: 16),
              
              // Date Picker
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) setState(() => _scheduledDate = date);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: context.t('scheduleDate'),
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _scheduledDate != null 
                        ? '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}' 
                        : context.t('selectDate'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfirmation() {
    return Column(
      children: [
        // Payment Method
        PaymentMethodSelector(
          selectedMethod: _selectedPaymentMethod,
          onMethodChanged: (method) => setState(() => _selectedPaymentMethod = method),
          walletBalance: 150.0, // Mock wallet balance
        ),
        
        const SizedBox(height: 24),
        
        // Coupon
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _couponController,
                decoration: InputDecoration(
                  labelText: context.t('couponCode'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.confirmation_number_outlined),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isValidatingCoupon ? null : _applyCoupon,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              child: _isValidatingCoupon 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(context.t('applyCoupon')),
            ),
          ],
        ),
        
        if (_appliedCoupon != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${context.t('couponApplied')} (-${_appliedCoupon!.discountAmount} ${context.t('currency')})',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

        const SizedBox(height: 24),
        
        // Final Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _summaryRow(context.t('inspectionPrice'), '50 ${context.t('currency')}'),
              if (_appliedCoupon != null)
                _summaryRow(context.t('discount'), '-${_appliedCoupon!.discountAmount} ${context.t('currency')}', isDiscount: true),
              const Divider(height: 24),
              _summaryRow(context.t('total'), '${_calculateTotal()} ${context.t('currency')}', isTotal: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isDiscount ? Colors.green : AppTheme.textPrimaryColor,
          )),
          Text(value, style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
            color: isDiscount ? Colors.green : AppTheme.textPrimaryColor,
          )),
        ],
      ),
    );
  }

  double _calculateTotal() {
    double base = 50.0;
    if (_appliedCoupon != null) {
      return _couponService.calculateDiscount(base, _appliedCoupon!);
    }
    return base;
  }
}
