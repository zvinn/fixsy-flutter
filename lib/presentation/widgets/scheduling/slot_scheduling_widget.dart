import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

enum BookingType { now, scheduled }

enum RecurringType { none, weekly, monthly, yearly }

class SchedulingData {
  final BookingType bookingType;
  final DateTime scheduledDate;
  final String timeSlot;
  final TimeOfDay? customTime;
  final RecurringType recurringType;

  const SchedulingData({
    required this.bookingType,
    required this.scheduledDate,
    required this.timeSlot,
    this.customTime,
    required this.recurringType,
  });

  String get formattedSummary {
    if (bookingType == BookingType.now) {
      return 'حجز فوري (يصل الفني خلال 30 - 60 دقيقة ⚡)';
    }

    final dateStr = '${scheduledDate.year}/${scheduledDate.month}/${scheduledDate.day}';
    final timeStr = customTime != null
        ? '${customTime!.hour.toString().padLeft(2, '0')}:${customTime!.minute.toString().padLeft(2, '0')}'
        : timeSlot;

    var recurringStr = '';
    if (recurringType == RecurringType.weekly) recurringStr = ' [تكرار أسبوعي]';
    if (recurringType == RecurringType.monthly) recurringStr = ' [تكرار شهري]';
    if (recurringType == RecurringType.yearly) recurringStr = ' [تكرار سنوي]';

    return '$dateStr | $timeStr$recurringStr';
  }
}

class SlotSchedulingWidget extends StatefulWidget {
  final SchedulingData? initialData;
  final ValueChanged<SchedulingData> onSchedulingChanged;

  const SlotSchedulingWidget({
    super.key,
    this.initialData,
    required this.onSchedulingChanged,
  });

  @override
  State<SlotSchedulingWidget> createState() => _SlotSchedulingWidgetState();
}

class _SlotSchedulingWidgetState extends State<SlotSchedulingWidget> {
  late BookingType _bookingType;
  late DateTime _selectedDate;
  late String _selectedTimeSlot;
  TimeOfDay? _customTime;
  late RecurringType _recurringType;

  final List<Map<String, String>> _timeSlots = [
    {'id': 'morning', 'title': 'الصباح ☀️', 'time': '09:00 ص - 12:00 م'},
    {'id': 'afternoon', 'title': 'الظهيرة 🌤️', 'time': '12:00 م - 04:00 م'},
    {'id': 'evening', 'title': 'المساء 🌆', 'time': '04:00 م - 08:00 م'},
    {'id': 'night', 'title': 'سهرة 🌙', 'time': '08:00 م - 11:00 م'},
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _bookingType = widget.initialData?.bookingType ?? BookingType.scheduled;
    _selectedDate = widget.initialData?.scheduledDate ?? DateTime(now.year, now.month, now.day);
    _selectedTimeSlot = widget.initialData?.timeSlot ?? '09:00 ص - 12:00 م';
    _customTime = widget.initialData?.customTime;
    _recurringType = widget.initialData?.recurringType ?? RecurringType.none;
  }

  void _notifyChange() {
    widget.onSchedulingChanged(
      SchedulingData(
        bookingType: _bookingType,
        scheduledDate: _selectedDate,
        timeSlot: _selectedTimeSlot,
        customTime: _customTime,
        recurringType: _recurringType,
      ),
    );
  }

  String _getArabicWeekday(int weekday) {
    switch (weekday) {
      case DateTime.saturday:
        return 'السبت';
      case DateTime.sunday:
        return 'الأحد';
      case DateTime.monday:
        return 'الإثنين';
      case DateTime.tuesday:
        return 'الثلاثاء';
      case DateTime.wednesday:
        return 'الأربعاء';
      case DateTime.thursday:
        return 'الخميس';
      case DateTime.friday:
        return 'الجمعة';
      default:
        return '';
    }
  }

  String _getArabicMonth(int month) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Toggle: Now vs Scheduled
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() => _bookingType = BookingType.now);
                    _notifyChange();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _bookingType == BookingType.now ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _bookingType == BookingType.now
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          size: 18,
                          color: _bookingType == BookingType.now ? AppTheme.primaryColor : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'فوري الآن (30-60 دقيقة)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _bookingType == BookingType.now ? AppTheme.primaryColor : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() => _bookingType = BookingType.scheduled);
                    _notifyChange();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _bookingType == BookingType.scheduled ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _bookingType == BookingType.scheduled
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 18,
                          color: _bookingType == BookingType.scheduled ? AppTheme.primaryColor : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'جدولة موعد مسبق',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _bookingType == BookingType.scheduled ? AppTheme.primaryColor : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Body based on selected type
        if (_bookingType == BookingType.now) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.successColor.withOpacity(0.08),
                  AppTheme.primaryColor.withOpacity(0.04),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.flash_on_rounded,
                    color: AppTheme.successColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'خدمة الصيانة السريعة والفورية',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'سيتم إرسال الفني الأقرب والأعلى تقييماً فور تأكيد الحجز، ويصل خلال 30 - 60 دقيقة مع تتبع حي.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Date Selection Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.event_available_rounded, size: 18, color: AppTheme.primaryColor),
                  SizedBox(width: 6),
                  Text(
                    'اختر تاريخ الزيارة',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 60)),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                    _notifyChange();
                  }
                },
                icon: const Icon(Icons.date_range_rounded, size: 16),
                label: const Text('تاريخ مخصص', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Horizontal Date Cards (14 days)
          SizedBox(
            height: 104,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 14,
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index));
                final isSelected = _selectedDate.year == date.year &&
                    _selectedDate.month == date.month &&
                    _selectedDate.day == date.day;

                String topLabel = _getArabicWeekday(date.weekday);
                if (index == 0) topLabel = 'اليوم';
                if (index == 1) topLabel = 'غداً';

                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDate = DateTime(date.year, date.month, date.day);
                      });
                      _notifyChange();
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 70,
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            topLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getArabicMonth(date.month),
                            style: TextStyle(
                              fontSize: 9,
                              color: isSelected ? Colors.white70 : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          // Time Slots Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 18, color: AppTheme.primaryColor),
                  SizedBox(width: 6),
                  Text(
                    'الفترة الزمنية المفضلة',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _customTime ?? const TimeOfDay(hour: 10, minute: 0),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _customTime = pickedTime;
                      _selectedTimeSlot =
                          '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')} (وقت دقيق)';
                    });
                    _notifyChange();
                  }
                },
                icon: const Icon(Icons.timer_outlined, size: 16),
                label: Text(
                  _customTime != null
                      ? '${_customTime!.hour.toString().padLeft(2, '0')}:${_customTime!.minute.toString().padLeft(2, '0')}'
                      : 'وقت محدد بالدقيقة',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Grid of standard time slots
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _timeSlots.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final slot = _timeSlots[index];
              final isSelected = _customTime == null && _selectedTimeSlot == slot['time'];

              return InkWell(
                onTap: () {
                  setState(() {
                    _customTime = null;
                    _selectedTimeSlot = slot['time']!;
                  });
                  _notifyChange();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor.withOpacity(0.08) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                      width: isSelected ? 1.8 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            slot['title']!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        slot['time']!,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? AppTheme.primaryColor.withOpacity(0.9) : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // 3. Recurring Booking (تكرار الحجز)
          Row(
            children: [
              const Icon(Icons.repeat_rounded, size: 18, color: AppTheme.primaryColor),
              const SizedBox(width: 6),
              const Text(
                'تكرار الموعد تلقائياً',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'وفر 10% 🎁',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Recurring type chips
          Row(
            children: [
              _buildRecurringChip(RecurringType.none, 'مرة واحدة'),
              const SizedBox(width: 8),
              _buildRecurringChip(RecurringType.weekly, 'أسبوعياً'),
              const SizedBox(width: 8),
              _buildRecurringChip(RecurringType.monthly, 'شهرياً'),
              const SizedBox(width: 8),
              _buildRecurringChip(RecurringType.yearly, 'سنوياً'),
            ],
          ),

          if (_recurringType != RecurringType.none) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 16, color: Colors.teal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _recurringType == RecurringType.weekly
                          ? 'سيتم تكرار هذا الحجز كل أسبوع تلقائياً مع تذكير مسبق وإمكانية التعديل أو الإلغاء مجاناً.'
                          : _recurringType == RecurringType.monthly
                              ? 'سيتم تكرار هذا الحجز كل شهر للحفاظ على الصيانة الوقائية لمنزلك بتخفيض دائم.'
                              : 'صيانة وقائية دورية سنوية للأجهزة المنزلية والتكييفات.',
                      style: TextStyle(fontSize: 11, color: Colors.teal.shade900, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildRecurringChip(RecurringType type, String label) {
    final isSelected = _recurringType == type;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _recurringType = type);
          _notifyChange();
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.grey.shade800,
            ),
          ),
        ),
      ),
    );
  }
}
