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
          LatLng(_defaultLocation.latitude + 0.01, _defaultLocation.longitude + 0.01);
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
    // Simulate real-time updates every 5 seconds
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_techLocation != null && _clientLocation != null) {
        _simulateTechnicianMovement();
      }
    });
  }

  void _simulateTechnicianMovement() {
    if (_techLocation == null || _clientLocation == null) return;
    
    // Simulate technician moving closer to client
    final latDiff = (_clientLocation!.latitude - _techLocation!.latitude) * 0.1;
    final lngDiff = (_clientLocation!.longitude - _techLocation!.longitude) * 0.1;
    
    if (latDiff.abs() < 0.0001 && lngDiff.abs() < 0.0001) {
      // Technician arrived
      _locationUpdateTimer?.cancel();
      _estimatedTime = 'وصل الفني!';
      _distance = '';
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 الفني وصل إلى موقعك!'),
          backgroundColor: Colors.green,
        ),
      );
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

  void _updateMarkers() {
    _markers.clear();
    
    // Technician marker
    if (_techLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('technician'),
          position: _techLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: widget.technicianName ?? 'الفني',
            snippet: 'في الطريق إليك',
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
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(
            title: 'موقعك',
          ),
        ),
      );
    }
  }

  void _calculateRoute() {
    if (_techLocation == null || _clientLocation == null) return;
    
    // Calculate distance
    final distanceInMeters = Geolocator.distanceBetween(
      _techLocation!.latitude,
      _techLocation!.longitude,
      _clientLocation!.latitude,
      _clientLocation!.longitude,
    );
    
    // Calculate estimated time (assuming 30 km/h average speed)
    final timeInMinutes = (distanceInMeters / 1000) / 30 * 60;
    
    setState(() {
      if (distanceInMeters < 1000) {
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
        _estimatedTime = '$hours ساعة و $mins دقيقة';
      }
    });
    
    // Draw route polyline
    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [_techLocation!, _clientLocation!],
        color: AppTheme.primaryColor,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
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
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        appBar: AppBar(
          title: const Text('تتبع الفني'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  // Google Map
                  GoogleMap(
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
                  
                  // Info Card
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildInfoCard(isDark),
                  ),
                  
                  // Center button
                  Positioned(
                    bottom: 200,
                    left: 16,
                    child: FloatingActionButton.small(
                      onPressed: _centerMap,
                      backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
                      child: Icon(
                        Icons.center_focus_strong,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.engineering,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.technicianName ?? 'الفني',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'في الطريق إليك',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
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
                      // Navigate to Chat
                       Navigator.pushNamed(context, '/chat', arguments: {
                         'userId': widget.technicianId,
                         'userName': widget.technicianName
                       });
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chat,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('جاري الاتصال بالفني...')),
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.green,
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
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.timer,
                  label: 'الوقت المتوقع',
                  value: _estimatedTime,
                  isDark: isDark,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: isDark ? Colors.white12 : Colors.grey.shade200,
              ),
              Expanded(
                child: _InfoItem(
                  icon: Icons.route,
                  label: 'المسافة',
                  value: _distance,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, end: 0, duration: 500.ms);
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
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? '-' : value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}
