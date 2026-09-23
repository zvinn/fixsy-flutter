import 'package:flutter/material.dart';
import '../../widgets/booking/booking_modal.dart';

class NewRequestScreen extends StatelessWidget {
  final String? initialServiceType;
  final String? initialDescription;

  const NewRequestScreen({
    super.key, 
    this.initialServiceType,
    this.initialDescription,
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
          initialDescription: initialDescription,
          onSubmit: () {
            // Can trigger additional actions here
          },
        ),
      ),
    );
  }
}
