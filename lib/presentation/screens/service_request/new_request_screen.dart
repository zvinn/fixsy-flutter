import 'package:flutter/material.dart';
import '../../widgets/booking/booking_modal.dart';

class NewRequestScreen extends StatelessWidget {
  final String? initialServiceType;

  const NewRequestScreen({
    super.key, 
    this.initialServiceType,
  });

  @override
  Widget build(BuildContext context) {
    // We treat the BookingModal as a full screen page content here
    // In a real modal usage, we'd use showModalBottomSheet
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BookingModal(
          initialServiceType: initialServiceType,
          onSubmit: () {
            // Can trigger additional actions here
          },
        ),
      ),
    );
  }
}
