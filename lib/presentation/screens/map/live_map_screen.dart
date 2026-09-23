import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme/app_theme.dart';

/// LiveMap Screen - Real-time technician tracking
class LiveMapScreen extends StatefulWidget {
  final String? technicianId;
  final String? technicianName;
  final LatLng? clientLocation;
  final LatLng? technicianLocation;

  const LiveMapScreen({
    super.key,
    this.technicianId,
    this.technicianName,
    this.clientLocation,
    this.technicianLocation,
  });

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  
  LatLng? _techLocation;
  LatLng? _clientLocation;
  
  String _estimatedTime = 'جاري الحساب...';
  String _distance = '';
  bool _isLoading = true;
  bool _hasArrived = false;
  MapType _currentMapType = MapType.normal;
  Timer? _locationUpdateTimer;

  // Cairo coordinates as default
  static const LatLng _defaultLocation = LatLng(30.0444, 31.2357);

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    setState(() => _isLoading = true);
    
    try {
      // Use provided locations or defaults
      _techLocation = widget.technicianLocation ?? 
          LatLng(_defaultLocation.latitude + 0.012, _defaultLocation.longitude + 0.012);
      _clientLocation = widget.clientLocation ?? _defaultLocation;
      
      _updateMarkers();
      _calculateRoute();
    } catch (e) {
      debugPrint('Error initializing map: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startLocationUpdates() {
    // Simulate real-time updates every 4 seconds
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_techLocation != null && _clientLocation != null && !_hasArrived) {
        _simulateTechnicianMovement();
      }
    });
  }

  void _simulateTechnicianMovement() {
    if (_techLocation == null || _clientLocation == null) return;
    
    // Simulate technician moving closer to client (15% per tick)
    final latDiff = (_clientLocation!.latitude - _techLocation!.latitude) * 0.15;
    final lngDiff = (_clientLocation!.longitude - _techLocation!.longitude) * 0.15;
    
    if (latDiff.abs() < 0.0003 && lngDiff.abs() < 0.0003) {
      // Technician arrived
      _locationUpdateTimer?.cancel();
      setState(() {
        _techLocation = _clientLocation;
        _hasArrived = true;
        _estimatedTime = 'وصل الفني!';
        _distance = 'في موقعك الآن';
        _updateMarkers();
        _polylines.clear();
      });
      
      if (mounted) {
        _showArrivalDialog();
      }
    } else {
      setState(() {
        _techLocation = LatLng(
          _techLocation!.latitude + latDiff,
          _techLocation!.longitude + lngDiff,
        );
        _updateMarkers();
        _calculateRoute();
      });
    }
  }

  void _showArrivalDialog() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF10B981), width: 2),
              ),
              child: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              'وصل ${widget.technicianName ?? "الفني"} إلى موقعك!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'الفني جاهز الآن للمعاينة وبدء أعمال الصيانة. يرجى الترحيب به واستقباله.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/chat', arguments: {
                        'conversationId': widget.technicianId ?? 'conv_123',
                        'otherUserName': widget.technicianName ?? 'الفني',
                        'otherUserId': widget.technicianId ?? '',
                      });
                    },
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('محادثة الفني'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم بدء تنفيذ الخدمة بنجاح.'),
                          backgroundColor: AppTheme.successColor,
                        ),
                      );
                    },
                    icon: const Icon(Icons.handyman_outlined),
                    label: const Text('بدء الخدمة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _updateMarkers() {
    _markers.clear();
    
    // Technician marker
    if (_techLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('technician'),
          position: _techLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _hasArrived ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueBlue,
          ),
          infoWindow: InfoWindow(
            title: widget.technicianName ?? 'الفني',
            snippet: _hasArrived ? 'وصل إلى موقعك' : 'في الطريق إليك',
          ),
        ),
      );
    }
    
    // Client marker
    if (_clientLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('client'),
          position: _clientLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: const InfoWindow(
            title: 'موقعك (مكان الخدمة)',
          ),
        ),
      );
    }
  }

  void _calculateRoute() {
    if (_techLocation == null || _clientLocation == null || _hasArrived) return;
    
    // Calculate distance
    final distanceInMeters = Geolocator.distanceBetween(
      _techLocation!.latitude,
      _techLocation!.longitude,
      _clientLocation!.latitude,
      _clientLocation!.longitude,
    );
    
    // Calculate estimated time (assuming 30 km/h average city speed)
    final timeInMinutes = (distanceInMeters / 1000) / 30 * 60;
    
    setState(() {
      if (distanceInMeters < 100) {
        _distance = 'أقل من 100 متر';
      } else if (distanceInMeters < 1000) {
        _distance = '${distanceInMeters.toStringAsFixed(0)} متر';
      } else {
        _distance = '${(distanceInMeters / 1000).toStringAsFixed(1)} كم';
      }
      
      if (timeInMinutes < 1) {
        _estimatedTime = 'أقل من دقيقة';
      } else if (timeInMinutes < 60) {
        _estimatedTime = '${timeInMinutes.toStringAsFixed(0)} دقيقة';
      } else {
        final hours = (timeInMinutes / 60).floor();
        final mins = (timeInMinutes % 60).toStringAsFixed(0);
        _estimatedTime = '$hours س و $mins د';
      }
    });
    
    // Draw route polyline
    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [_techLocation!, _clientLocation!],
        color: AppTheme.primaryColor,
        width: 5,
        patterns: [PatternItem.dash(15), PatternItem.gap(8)],
      ),
    );
  }

  void _centerMap() {
    if (_mapController == null) return;
    
    if (_techLocation != null && _clientLocation != null) {
      final bounds = LatLngBounds(
        southwest: LatLng(
          _techLocation!.latitude < _clientLocation!.latitude 
              ? _techLocation!.latitude : _clientLocation!.latitude,
          _techLocation!.longitude < _clientLocation!.longitude 
              ? _techLocation!.longitude : _clientLocation!.longitude,
        ),
        northeast: LatLng(
          _techLocation!.latitude > _clientLocation!.latitude 
              ? _techLocation!.latitude : _clientLocation!.latitude,
          _techLocation!.longitude > _clientLocation!.longitude 
              ? _techLocation!.longitude : _clientLocation!.longitude,
        ),
      );
      
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 90),
      );
    }
  }

  void _callTechnician() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.phone_forwarded, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text('الاتصال بـ ${widget.technicianName ?? "الفني"}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('رقم الهاتف للتواصل:'),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.phone, size: 18, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    '+20 101 234 5678',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'متاح للاتصال المباشر بشأن تفاصيل العنوان وتسهيل الوصول.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('جاري بدء المكالمة مع الفني...'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            icon: const Icon(Icons.call),
            label: const Text('اتصال الآن'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        appBar: AppBar(
          title: const Text('تتبع مسار الفني المباشر'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                _currentMapType == MapType.normal ? Icons.layers_outlined : Icons.map_outlined,
              ),
              tooltip: 'تغيير نوع الخريطة',
              onPressed: () {
                setState(() {
                  _currentMapType = _currentMapType == MapType.normal 
                      ? MapType.hybrid 
                      : MapType.normal;
                });
              },
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  // Google Map
                  GoogleMap(
                    mapType: _currentMapType,
                    initialCameraPosition: CameraPosition(
                      target: _clientLocation ?? _defaultLocation,
                      zoom: 14,
                    ),
                    markers: _markers,
                    polylines: _polylines,
                    onMapCreated: (controller) {
                      _mapController = controller;
                      _centerMap();
                      if (isDark) {
                        _setDarkMapStyle();
                      }
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                  ),
                  
                  // Live Status Pill (Top)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: _hasArrived ? const Color(0xFF10B981) : AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _hasArrived ? Icons.check_circle : Icons.near_me_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _hasArrived
                                ? 'وصل الفني إلى عنوانك'
                                : 'الفني متوجه إليك الآن - وصول خلال $_estimatedTime',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: -0.5, end: 0),
                  ),

                  // Map Re-Center Button
                  Positioned(
                    bottom: 220,
                    left: 16,
                    child: FloatingActionButton.small(
                      heroTag: 'center_map_fab',
                      onPressed: _centerMap,
                      backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
                      elevation: 4,
                      child: Icon(
                        Icons.center_focus_strong,
                        color: isDark ? Colors.white : AppTheme.primaryColor,
                      ),
                    ),
                  ),

                  // Bottom Info Card
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildInfoCard(isDark),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.engineering_rounded,
                  color: AppTheme.primaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.technicianName ?? 'فني Fixsy المعتمد',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _hasArrived ? Colors.green : Colors.amber.shade700,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _hasArrived ? 'وصل للوجهة' : 'في الطريق بالسيارة / الدراجة',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/chat', arguments: {
                        'conversationId': widget.technicianId ?? 'conv_123',
                        'otherUserName': widget.technicianName ?? 'الفني',
                        'otherUserId': widget.technicianId ?? '',
                      });
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: _callTechnician,
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.phone,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.timer_outlined,
                  label: 'الوقت المقدر للوصول',
                  value: _estimatedTime,
                  isDark: isDark,
                ),
              ),
              Container(
                width: 1,
                height: 38,
                color: isDark ? Colors.white12 : Colors.grey.shade200,
              ),
              Expanded(
                child: _InfoItem(
                  icon: Icons.alt_route_rounded,
                  label: 'المسافة المتبقية',
                  value: _distance,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, end: 0, duration: 400.ms);
  }

  void _setDarkMapStyle() async {
    const darkMapStyle = '''
    [
      {"elementType": "geometry", "stylers": [{"color": "#242f3e"}]},
      {"elementType": "labels.text.stroke", "stylers": [{"color": "#242f3e"}]},
      {"elementType": "labels.text.fill", "stylers": [{"color": "#746855"}]},
      {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#38414e"}]},
      {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#212a37"}]},
      {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#746855"}]},
      {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#17263c"}]}
    ]
    ''';
    _mapController?.setMapStyle(darkMapStyle);
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 22,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white38 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? '-' : value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}
