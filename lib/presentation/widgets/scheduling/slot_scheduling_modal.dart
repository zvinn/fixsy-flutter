import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'slot_scheduling_widget.dart';

Future<SchedulingData?> showSlotSchedulingBottomSheet({
  required BuildContext context,
  SchedulingData? initialData,
  String? technicianName,
  String? serviceTitle,
}) {
  return showModalBottomSheet<SchedulingData>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _SlotSchedulingModal(
      initialData: initialData,
      technicianName: technicianName,
      serviceTitle: serviceTitle,
    ),
  );
}

class _SlotSchedulingModal extends StatefulWidget {
  final SchedulingData? initialData;
  final String? technicianName;
  final String? serviceTitle;

  const _SlotSchedulingModal({
    this.initialData,
    this.technicianName,
    this.serviceTitle,
  });

  @override
  State<_SlotSchedulingModal> createState() => _SlotSchedulingModalState();
}

class _SlotSchedulingModalState extends State<_SlotSchedulingModal> {
  late SchedulingData _schedulingData;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _schedulingData = widget.initialData ??
        SchedulingData(
          bookingType: BookingType.scheduled,
          scheduledDate: DateTime(now.year, now.month, now.day),
          timeSlot: '09:00 ص - 12:00 م',
          recurringType: RecurringType.none,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Top drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'تحديد موعد الخدمة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      if (widget.serviceTitle != null || widget.technicianName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${widget.serviceTitle ?? 'خدمة منزلية'} • ${widget.technicianName ?? 'فني معتمد'}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SlotSchedulingWidget(
                initialData: _schedulingData,
                onSchedulingChanged: (data) {
                  setState(() => _schedulingData = data);
                },
              ),
            ),
          ),

          // Footer Confirmation Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, _schedulingData);
                  },
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: Text(
                    _schedulingData.bookingType == BookingType.now
                        ? 'تأكيد الحجز الفوري الآن ⚡'
                        : 'تأكيد وحفظ الموعد المحدد',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
