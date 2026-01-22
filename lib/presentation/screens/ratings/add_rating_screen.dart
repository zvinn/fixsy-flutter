import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/booking_model.dart';
import '../../providers/rating_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/rating_widgets.dart';

/// Add Rating Screen
/// Allow users to rate a completed booking
class AddRatingScreen extends StatefulWidget {
  final Booking booking;

  const AddRatingScreen({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  State<AddRatingScreen> createState() => _AddRatingScreenState();
}

class _AddRatingScreenState extends State<AddRatingScreen> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار التقييم'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final success = await ratingProvider.addRating(
      bookingId: widget.booking.id,
      technicianId: widget.booking.technicianId,
      userId: user.id,
      rating: _rating,
      comment: _commentController.text.trim().isEmpty 
          ? null 
          : _commentController.text.trim(),
      userName: user.displayName,
      technicianName: widget.booking.technicianName,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة التقييم بنجاح ✅'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ratingProvider.error ?? 'فشل إضافة التقييم'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getRatingLabel() {
    if (_rating == 0) return 'اختر التقييم';
    if (_rating == 1) return 'سيء جداً 😞';
    if (_rating == 2) return 'سيء';
    if (_rating == 3) return 'متوسط';
    if (_rating == 4) return 'جيد 👍';
    return 'ممتاز 🌟';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقييم الخدمة'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Booking Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.booking.serviceName ?? 'الخدمة',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'الفني: ${widget.booking.technicianName ?? "غير محدد"}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.booking.scheduledDate.day}/${widget.booking.scheduledDate.month}/${widget.booking.scheduledDate.year}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Rating Section
            Center(
              child: Column(
                children: [
                  const Text(
                    'كيف كانت تجربتك؟',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Star Rating Input
                  StarRatingInput(
                    initialRating: _rating,
                    size: 50,
                    onRatingChanged: (rating) {
                      setState(() {
                        _rating = rating;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Rating Label
                  Text(
                    _getRatingLabel(),
                    style: TextStyle(
                      fontSize: 18,
                      color: _rating >= 4 ? Colors.green : Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Comment Section
            const Text(
              'أخبرنا المزيد (اختياري)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'اكتب تعليقك هنا...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitRating,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'إرسال التقييم',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
