import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bookings_provider.dart';
import '../../../data/models/booking_model.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../widgets/common/skeleton_loaders.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  String _filterStatus = 'all'; // all, pending, in_progress, completed

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final authProvider = context.read<AuthProvider>();
    final bookingsProvider = context.read<BookingsProvider>();

    if (authProvider.currentUser != null) {
      await bookingsProvider.loadUserBookings(authProvider.currentUser!.id);
    }
  }

  List<Booking> _filterBookings(List<Booking> bookings) {
    if (_filterStatus == 'all') {
      return bookings;
    }
    if (_filterStatus == 'in_progress') {
      return bookings.where((b) => b.status == 'in_progress' || b.status == 'accepted').toList();
    }
    return bookings.where((b) => b.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          title: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حجوزاتي',
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                Text(
                  'تابع حالة طلباتك الحالية وتاريخ الصيانات السابقة',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: IconButton(
                onPressed: _loadBookings,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.refreshCw, size: 18, color: AppTheme.primaryColor),
                ),
                tooltip: 'تحديث الحجوزات',
              ),
            ),
          ],
        ),
        body: Consumer<BookingsProvider>(
          builder: (context, bookingsProvider, _) {
            // Skeleton Loader
            if (bookingsProvider.isLoading) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    height: 64,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        return Container(
                          width: 110,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: 4,
                      itemBuilder: (context, index) => const BookingCardSkeleton(),
                    ),
                  ),
                ],
              );
            }

            final filteredBookings = _filterBookings(bookingsProvider.bookings);

            return Column(
              children: [
                // Modern Pill Filters Bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterPill('all', 'الكل', LucideIcons.layers, bookingsProvider.bookings.length),
                        const SizedBox(width: 8),
                        _buildFilterPill(
                          'pending',
                          'قيد الانتظار',
                          LucideIcons.clock,
                          bookingsProvider.bookings.where((b) => b.status == 'pending').length,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterPill(
                          'in_progress',
                          'جاري التنفيذ',
                          LucideIcons.wrench,
                          bookingsProvider.bookings
                              .where((b) => b.status == 'in_progress' || b.status == 'accepted')
                              .length,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterPill(
                          'completed',
                          'مكتملة',
                          LucideIcons.checkCircle2,
                          bookingsProvider.bookings.where((b) => b.status == 'completed').length,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // Bookings List
                Expanded(
                  child: filteredBookings.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: AppTheme.primaryColor,
                          onRefresh: _loadBookings,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final responsive = context.responsive;
                              if (responsive.isTablet || responsive.isDesktop) {
                                final crossAxisCount = responsive.isDesktop ? 3 : 2;
                                return GridView.builder(
                                  padding: EdgeInsets.all(responsive.horizontalPadding),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    childAspectRatio: 1.35,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                                  itemCount: filteredBookings.length,
                                  itemBuilder: (context, index) {
                                    return _buildBookingCard(filteredBookings[index]);
                                  },
                                );
                              }
                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                itemCount: filteredBookings.length,
                                itemBuilder: (context, index) {
                                  return _buildBookingCard(filteredBookings[index]);
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterPill(String status, String label, IconData icon, int count) {
    final isSelected = _filterStatus == status;
    return InkWell(
      onTap: () {
        setState(() {
          _filterStatus = status;
        });
      },
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                )
              : null,
          color: isSelected ? null : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1E3A8A).withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : AppTheme.textSecondaryLight,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textPrimaryLight,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.25) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppTheme.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showBookingDetails(booking),
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Service Icon + Title + Status Pill
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getServiceGradient(booking.serviceName),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _getServiceGradient(booking.serviceName).first.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _getServiceIcon(booking.serviceName),
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.serviceName ?? 'خدمة صيانة',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'كود الطلب: #${booking.id.length > 6 ? booking.id.substring(0, 6).toUpperCase() : booking.id.toUpperCase()}',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(booking.status),
                ],
              ),

              const SizedBox(height: 14),

              // Info Row (Date & Address & Price)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.calendar, size: 14, color: AppTheme.primaryLight),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _formatDate(booking.scheduledDate),
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryLight,
                            ),
                          ),
                        ),
                        Text(
                          '${booking.totalPrice.toStringAsFixed(0)} ج.م',
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin, size: 14, color: AppTheme.textSecondaryLight),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            booking.address,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: AppTheme.textSecondaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Technician Row (If assigned)
              if (booking.technicianName != null) ...[
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.pushNamed(context, '/technician-profile', arguments: {
                      'techId': booking.technicianId,
                      'techName': booking.technicianName!,
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                            ),
                          ),
                          child: const Center(
                            child: Icon(LucideIcons.user, size: 14, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الفني: ${booking.technicianName!}',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'عرض الملف ←',
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Actions Row
              if (booking.status == 'pending') ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _cancelBooking(booking),
                    icon: const Icon(LucideIcons.xCircle, size: 16, color: Color(0xFFEF4444)),
                    label: Text(
                      'إلغاء الحجز',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      backgroundColor: const Color(0xFFFEF2F2),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],

              if (booking.status == 'accepted' || booking.status == 'in_progress') ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/live-map', arguments: {
                            'technicianId': booking.technicianId,
                            'technicianName': booking.technicianName ?? 'فني Fixsy المعتمد',
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E3A8A).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.navigation, size: 16, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                'تتبع الفني على الخريطة',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/chat', arguments: {
                            'conversationId': booking.id,
                            'otherUserName': booking.technicianName ?? 'الفني',
                            'otherUserId': booking.technicianId,
                          });
                        },
                        icon: const Icon(LucideIcons.messageSquare, size: 16, color: AppTheme.primaryColor),
                        label: Text(
                          'محادثة',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFBFDBFE)),
                          backgroundColor: const Color(0xFFEFF6FF),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              if (booking.status == 'completed') ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.addRating,
                        arguments: booking,
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.star, size: 16, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            booking.isRated ? 'تم تقييم الخدمة ⭐' : 'تقييم الخدمة والفني ⭐',
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgLight;
    Color border;
    Color textColor;
    IconData icon;
    String text;

    switch (status) {
      case 'pending':
        bgLight = const Color(0xFFFEF3C7);
        border = const Color(0xFFFDE68A);
        textColor = const Color(0xFFD97706);
        icon = LucideIcons.clock;
        text = 'قيد الانتظار';
        break;
      case 'accepted':
      case 'in_progress':
        bgLight = const Color(0xFFDBEAFE);
        border = const Color(0xFFBFDBFE);
        textColor = const Color(0xFF2563EB);
        icon = LucideIcons.wrench;
        text = status == 'accepted' ? 'تم القبول' : 'جاري التنفيذ';
        break;
      case 'completed':
        bgLight = const Color(0xFFD1FAE5);
        border = const Color(0xFFA7F3D0);
        textColor = const Color(0xFF059669);
        icon = LucideIcons.checkCircle2;
        text = 'مكتمل';
        break;
      case 'cancelled':
        bgLight = const Color(0xFFFEE2E2);
        border = const Color(0xFFFECACA);
        textColor = const Color(0xFFDC2626);
        icon = LucideIcons.xCircle;
        text = 'ملغي';
        break;
      default:
        bgLight = const Color(0xFFF1F5F9);
        border = const Color(0xFFE2E8F0);
        textColor = const Color(0xFF64748B);
        icon = LucideIcons.helpCircle;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEFF6FF),
                border: Border.all(color: const Color(0xFFDBEAFE), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.calendarX,
                  size: 48,
                  color: AppTheme.primaryLight,
                ),
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text(
              _filterStatus == 'all'
                  ? 'لا توجد أي حجوزات بعد'
                  : 'لا توجد حجوزات ${_getFilterLabel()}',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اطلب فني معتمد لأي صيانة منزلية وتابع وصوله خطوة بخطوة',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppTheme.textSecondaryLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () {
                Navigator.of(context).pushNamed('/new-request');
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.plusCircle, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'طلب خدمة جديدة الآن',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFilterLabel() {
    switch (_filterStatus) {
      case 'pending':
        return 'قيد الانتظار';
      case 'in_progress':
        return 'جاري تنفيذها';
      case 'completed':
        return 'مكتملة';
      default:
        return '';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  List<Color> _getServiceGradient(String? serviceName) {
    final name = (serviceName ?? '').toLowerCase();
    if (name.contains('سباك') || name.contains('plumb') || name.contains('مياه')) {
      return [const Color(0xFF0284C7), const Color(0xFF38BDF8)];
    } else if (name.contains('كهرب') || name.contains('elect')) {
      return [const Color(0xFFD97706), const Color(0xFFFBBF24)];
    } else if (name.contains('تكييف') || name.contains('ac') || name.contains('تبريد')) {
      return [const Color(0xFF0F766E), const Color(0xFF2DD4BF)];
    } else if (name.contains('نظاف') || name.contains('clean')) {
      return [const Color(0xFF059669), const Color(0xFF34D399)];
    }
    return [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)];
  }

  IconData _getServiceIcon(String? serviceName) {
    final name = (serviceName ?? '').toLowerCase();
    if (name.contains('سباك') || name.contains('plumb') || name.contains('مياه')) {
      return LucideIcons.droplets;
    } else if (name.contains('كهرب') || name.contains('elect')) {
      return LucideIcons.zap;
    } else if (name.contains('تكييف') || name.contains('ac') || name.contains('تبريد')) {
      return LucideIcons.wind;
    } else if (name.contains('نظاف') || name.contains('clean')) {
      return LucideIcons.sparkles;
    }
    return LucideIcons.wrench;
  }

  void _showBookingDetails(Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sheet handle
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تفاصيل الحجز',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryLight,
                    ),
                  ),
                  _buildStatusChip(booking.status),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              const SizedBox(height: 16),

              _buildDetailItem('الخدمة المطلوبة', booking.serviceName ?? 'غير محدد', LucideIcons.wrench),
              _buildDetailItem('عنوان الصيانة', booking.address, LucideIcons.mapPin),
              _buildDetailItem('الموعد المحدد', _formatDate(booking.scheduledDate), LucideIcons.calendar),
              _buildDetailItem('السعر الإجمالي', '${booking.totalPrice.toStringAsFixed(0)} ج.م', LucideIcons.banknote),

              if (booking.technicianName != null)
                _buildDetailItem('الفني المعتمد', booking.technicianName!, LucideIcons.user),

              if (booking.notes != null && booking.notes!.isNotEmpty)
                _buildDetailItem('ملاحظات العميل', booking.notes!, LucideIcons.fileText),

              const SizedBox(height: 24),

              // Chat button for active bookings
              if (booking.status != 'cancelled' && booking.status != 'completed')
                SizedBox(
                  width: double.infinity,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        AppRoutes.chatRoom,
                        arguments: booking,
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E3A8A).withOpacity(0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.messageCircle, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'دردشة فورية مع الفني',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Rating Button for completed bookings
              if (booking.status == 'completed' && !booking.isRated) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      final result = await Navigator.pushNamed(
                        context,
                        AppRoutes.addRating,
                        arguments: booking,
                      );
                      if (result == true) {
                        _loadBookings();
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withOpacity(0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.star, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'تقييم الخدمة والفني',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              // Cancel button for pending bookings
              if (booking.status == 'pending') ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _cancelBooking(booking);
                    },
                    icon: const Icon(LucideIcons.xCircle, size: 18, color: Color(0xFFEF4444)),
                    label: Text(
                      'إلغاء الحجز',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      backgroundColor: const Color(0xFFFEF2F2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: AppTheme.primaryLight),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    color: AppTheme.textSecondaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelBooking(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'إلغاء الحجز',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في إلغاء هذا الحجز؟',
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'تراجع',
                style: GoogleFonts.cairo(color: AppTheme.textSecondaryLight),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'نعم، إلغاء الحجز',
                style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );

    if (!mounted || confirmed != true) return;

    try {
      final authProvider = context.read<AuthProvider>();
      await context.read<BookingsProvider>().cancelBooking(
            bookingId: booking.id,
            userId: authProvider.currentUser!.id,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ تم إلغاء الحجز بنجاح', style: GoogleFonts.cairo()),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إلغاء الحجز: ${e.toString()}', style: GoogleFonts.cairo()),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}
