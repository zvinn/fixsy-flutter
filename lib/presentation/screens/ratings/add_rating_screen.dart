import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../data/models/booking_model.dart';
import '../../providers/rating_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/rating_widgets.dart';
import '../../../core/theme/app_theme.dart';

/// Add Rating Screen
/// Multi-criteria rating & feedback for completed service bookings
class AddRatingScreen extends StatefulWidget {
  const AddRatingScreen({
    required this.booking,
    super.key,
  });

  final Booking booking;

  @override
  State<AddRatingScreen> createState() => _AddRatingScreenState();
}

class _AddRatingScreenState extends State<AddRatingScreen> {
  double _overallRating = 5.0;
  double _punctualityRating = 5.0;
  double _qualityRating = 5.0;
  double _cleanlinessRating = 5.0;
  double _pricingRating = 5.0;

  final Set<String> _selectedTags = {};
  int _selectedTip = 0;
  bool _wouldWorkAgain = true;

  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _availableTags = [
    'شغل نظيف ومرتب ✨',
    'وصل في الموعد بالضبط ⏱️',
    'أمين ومحترم جداً 🤝',
    'سعر عادل ومناسب 💰',
    'خبير ومتمكن 🛠️',
    'شرح المشكلة بوضوح 💡',
    'استخدم قطع غيار أصلية 🔩',
    'أدوات حديثة ومتطورة ⚡',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_overallRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار التقييم العام'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    // Build comprehensive structured comment
    final commentBuffer = StringBuffer();
    if (_commentController.text.trim().isNotEmpty) {
      commentBuffer.writeln(_commentController.text.trim());
    }
    if (_selectedTags.isNotEmpty) {
      commentBuffer.writeln('المميزات: ${_selectedTags.join(" • ")}');
    }
    if (_selectedTip > 0) {
      commentBuffer.writeln('إكرامية إضافية: $_selectedTip ج.م');
    }
    commentBuffer.writeln('التعامل مجدداً: ${_wouldWorkAgain ? "نعم 👍" : "لا 👎"}');

    final success = await ratingProvider.addRating(
      bookingId: widget.booking.id,
      technicianId: widget.booking.technicianId,
      userId: user.id,
      rating: _overallRating,
      comment: commentBuffer.toString(),
      userName: user.displayName,
      technicianName: widget.booking.technicianName,
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      _showSuccessDialog();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ratingProvider.error ?? 'فشل إضافة التقييم'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppTheme.successColor, size: 56),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 16),
            const Text(
              'شكراً لمشاركتك رأيك! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'تقييمك يساعد الفنيين المتميزين ويرفع جودة الخدمات لجميع مستخدمي Fixsy.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            if (_selectedTip > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Text(
                  'تم إرسال إكرامية $_selectedTip ج.م للفني بنجاح 🎁',
                  style: TextStyle(color: Colors.amber.shade900, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('تم', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingLabel() {
    if (_overallRating >= 4.8) return 'خدمة استثنائية تفوق التوقعات! 🌟';
    if (_overallRating >= 4.0) return 'خدمة جيدة جداً ومرضية 👍';
    if (_overallRating >= 3.0) return 'خدمة مقبولة مع بعض الملاحظات 🤔';
    if (_overallRating >= 2.0) return 'أقل من المتوقع 😕';
    return 'تجربة غير مرضية إطلاقاً 😞';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('تقييم الخدمة والفني'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Service & Tech Card
            _buildBookingInfoCard().animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 16),

            // Overall Star Rating
            _buildOverallRatingCard().animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 16),

            // Multi-Criteria Detailed Ratings
            _buildMultiCriteriaCard().animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 16),

            // Quick Praise Tags
            _buildTagsCard().animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 16),

            // Tip Option
            _buildTipCard().animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 16),

            // Would Work Again Toggle
            _buildRehireCard().animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 16),

            // Detailed Comment
            _buildCommentCard().animate().fadeIn(delay: 450.ms),
            const SizedBox(height: 24),

            // Submit Button
            _buildSubmitButton().animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: const Icon(Icons.handyman, color: AppTheme.primaryColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.booking.serviceName ?? 'خدمة الصيانة',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'الفني: ${widget.booking.technicianName ?? "فني Fixsy المعتمد"}',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  'تاريخ الخدمة: ${widget.booking.scheduledDate.day}/${widget.booking.scheduledDate.month}/${widget.booking.scheduledDate.year}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallRatingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Text(
            'ما هو تقييمك العام للخدمة؟',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          StarRatingInput(
            initialRating: _overallRating,
            size: 46,
            onRatingChanged: (rating) {
              setState(() {
                _overallRating = rating;
              });
            },
          ),
          const SizedBox(height: 12),
          Text(
            _getRatingLabel(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _overallRating >= 4 ? AppTheme.successColor : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiCriteriaCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tune, size: 18, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text(
                'تقييم المعايير التفصيلية',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCriteriaRow('⏱️ الالتزام بالموعد وسرعة الحضور', _punctualityRating, (v) {
            setState(() => _punctualityRating = v);
          }),
          const Divider(height: 20),
          _buildCriteriaRow('🛠️ جودة وإتقان العمل والتشطيب', _qualityRating, (v) {
            setState(() => _qualityRating = v);
          }),
          const Divider(height: 20),
          _buildCriteriaRow('🧹 النظافة وحسن التعامل والأمانة', _cleanlinessRating, (v) {
            setState(() => _cleanlinessRating = v);
          }),
          const Divider(height: 20),
          _buildCriteriaRow('💰 عدالة السعر ووضوح التكلفة', _pricingRating, (v) {
            setState(() => _pricingRating = v);
          }),
        ],
      ),
    );
  }

  Widget _buildCriteriaRow(String title, double currentVal, ValueChanged<double> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final starVal = (index + 1).toDouble();
            final isFilled = starVal <= currentVal;
            return GestureDetector(
              onTap: () => onChanged(starVal),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  isFilled ? Icons.star : Icons.star_border,
                  size: 20,
                  color: isFilled ? Colors.amber : Colors.grey.shade300,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTagsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ما أكثر ما أعجبك في الفني؟ (اختر ما ينطبق)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return ChoiceChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
                selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                ),
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey.shade800,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.white,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.card_giftcard, size: 18, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'إكرامية تقديرية للفني (اختياري)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'تُحول مباشرة للفني كتحفيز له على إتقانه وأمانته في عمله.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
          ),
          const SizedBox(height: 12),
          Row(
            children: [0, 10, 20, 50].map((tip) {
              final isSelected = _selectedTip == tip;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: OutlinedButton(
                    onPressed: () => setState(() => _selectedTip = tip),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isSelected ? Colors.amber.shade50 : Colors.white,
                      side: BorderSide(
                        color: isSelected ? Colors.amber.shade800 : Colors.grey.shade300,
                        width: isSelected ? 1.5 : 1,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      tip == 0 ? 'بدون' : '$tip ج.م',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.amber.shade900 : Colors.grey.shade800,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRehireCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'هل ترغب في التعامل معه مستقبلاً؟',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                SizedBox(height: 2),
                Text(
                  'سنقوم بأولوية ترشيحه لك في طلباتك القادمة',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          Row(
            children: [
              ChoiceChip(
                label: const Text('نعم 👍'),
                selected: _wouldWorkAgain,
                onSelected: (val) => setState(() => _wouldWorkAgain = true),
                selectedColor: AppTheme.successColor.withValues(alpha: 0.15),
                side: BorderSide(color: _wouldWorkAgain ? AppTheme.successColor : Colors.grey.shade300),
                labelStyle: TextStyle(
                  color: _wouldWorkAgain ? AppTheme.successColor : Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('لا 👎'),
                selected: !_wouldWorkAgain,
                onSelected: (val) => setState(() => _wouldWorkAgain = false),
                selectedColor: AppTheme.errorColor.withValues(alpha: 0.15),
                side: BorderSide(color: !_wouldWorkAgain ? AppTheme.errorColor : Colors.grey.shade300),
                labelStyle: TextStyle(
                  color: !_wouldWorkAgain ? AppTheme.errorColor : Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ملاحظات إضافية وتعليقك (اختياري)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'شاركنا تفاصيل أكثر عن أداء الفني وسرعة إنجازه للخدمة...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitRating,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : const Text(
                'إرسال التقييم النهائي',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }
}
