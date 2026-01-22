import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bookings_provider.dart';
import '../../../data/models/booking_model.dart';
import '../../../core/utils/responsive_utils.dart';
import '../ratings/add_rating_screen.dart';
import '../chat/chat_room_screen.dart';
import '../../widgets/common/skeleton_loaders.dart';

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
    return bookings.where((b) => b.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حجوزاتي'),
        centerTitle: true,
      ),
      body: Consumer<BookingsProvider>(
        builder: (context, bookingsProvider, _) {
          // Loading with skeleton
          if (bookingsProvider.isLoading) {
            return Column(
              children: [
                // Filter chips skeleton
                Container(
                  padding: const EdgeInsets.all(16),
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return Container(
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    },
                  ),
                ),
                // List skeleton
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return const BookingCardSkeleton();
                    },
                  ),
                ),
              ],
            );
          }

          final filteredBookings = _filterBookings(bookingsProvider.bookings);

          return Column(
            children: [
              // Filter Chips
              Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'الكل', Icons.list),
                      const SizedBox(width: 8),
                      _buildFilterChip('pending', 'قيد الانتظار', Icons.pending),
                      const SizedBox(width: 8),
                      _buildFilterChip('in_progress', 'جاري التنفيذ', Icons.build),
                      const SizedBox(width: 8),
                      _buildFilterChip('completed', 'مكتمل', Icons.check_circle),
                    ],
                  ),
                ),
              ),

              // Bookings List
              Expanded(
                child: filteredBookings.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadBookings,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final responsive = context.responsive;
                            // Use grid on tablet/desktop, list on mobile
                            if (responsive.isTablet || responsive.isDesktop) {
                              final crossAxisCount = responsive.isDesktop ? 3 : 2;
                              return GridView.builder(
                                padding: EdgeInsets.all(responsive.horizontalPadding),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: 1.5,
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
                              padding: EdgeInsets.all(responsive.horizontalPadding),
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
    );
  }

  Widget _buildFilterChip(String status, String label, IconData icon) {
    final isSelected = _filterStatus == status;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        setState(() {
          _filterStatus = status;
        });
      },
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showBookingDetails(booking);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Service Name + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      booking.serviceName ?? 'خدمة',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  _buildStatusChip(booking.status),
                ],
              ),
              const SizedBox(height: 12),

              // Booking Info
              _buildInfoRow(
                Icons.location_on,
                'العنوان',
                booking.address,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.calendar_today,
                'الموعد',
                _formatDate(booking.scheduledDate),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.attach_money,
                'السعر',
                '${booking.totalPrice.toStringAsFixed(0)} ريال',
              ),
              
              if (booking.technicianName != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.person,
                  'الفني',
                  booking.technicianName!,
                ),
              ],

              // Actions
              if (booking.status == 'pending') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _cancelBooking(booking),
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text(
                          'إلغاء الحجز',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'قيد الانتظار';
        break;
      case 'accepted':
        color = Colors.blue;
        text = 'مقبول';
        break;
      case 'in_progress':
        color = Colors.purple;
        text = 'جاري التنفيذ';
        break;
      case 'completed':
        color = Colors.green;
        text = 'مكتمل';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'ملغي';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Chip(
      label: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _filterStatus == 'all'
                ? 'لا توجد حجوزات بعد'
                : 'لا توجد حجوزات ${_getFilterLabel()}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بطلب خدمة جديدة',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/new-request');
            },
            icon: const Icon(Icons.add),
            label: const Text('طلب خدمة جديدة'),
          ),
        ],
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

  void _showBookingDetails(Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تفاصيل الحجز',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  _buildStatusChip(booking.status),
                ],
              ),
              const Divider(height: 32),
              
              _buildDetailItem('الخدمة', booking.serviceName ?? 'غير محدد'),
              _buildDetailItem('العنوان', booking.address),
              _buildDetailItem('الموعد', _formatDate(booking.scheduledDate)),
              _buildDetailItem('السعر', '${booking.totalPrice} ريال'),
              
              if (booking.technicianName != null)
                _buildDetailItem('الفني', booking.technicianName!),
              
              if (booking.notes != null)
                _buildDetailItem('ملاحظات', booking.notes!),
              
              const SizedBox(height: 24),
              
              // Chat button for active bookings
              if (booking.status != 'cancelled' && booking.status != 'completed')
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatRoomScreen(booking: booking),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('دردشة مع الفني'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              
              const SizedBox(height: 12),
              
              // Rating Button for completed bookings
              if (booking.status == 'completed' && !booking.isRated)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddRatingScreen(booking: booking),
                        ),
                      );
                      if (result == true) {
                        _loadBookings(); // Refresh to update isRated status
                      }
                    },
                    icon: const Icon(Icons.star),
                    label: const Text('تقييم الخدمة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              
              // Show already rated message
              if (booking.status == 'completed' && booking.isRated)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        'تم تقييم هذه الخدمة ✅',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Cancel button for pending bookings
              if (booking.status == 'pending')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _cancelBooking(booking);
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text('إلغاء الحجز'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelBooking(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الحجز'),
        content: const Text('هل أنت متأكد من إلغاء هذا الحجز؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لا'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('نعم، إلغاء'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final authProvider = context.read<AuthProvider>();
        await context.read<BookingsProvider>().cancelBooking(
          bookingId: booking.id,
          userId: authProvider.currentUser!.id,
        );
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم إلغاء الحجز بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إلغاء الحجز: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
