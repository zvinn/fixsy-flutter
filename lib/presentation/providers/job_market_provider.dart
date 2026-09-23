import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/market_job_model.dart';
import '../../data/services/job_market_service.dart';

class JobMarketProvider extends ChangeNotifier {
  JobMarketProvider() {
    _initStream();
  }

  final JobMarketService _service = JobMarketService();
  StreamSubscription<List<MarketJob>>? _subscription;

  List<MarketJob> _jobs = [];
  bool _isLoading = true;
  String _selectedCategory = 'الكل';
  String _searchQuery = '';
  String? _currentUserId;
  String _userRole = 'client'; // 'client', 'tech', 'admin'

  List<MarketJob> get allJobs => _jobs;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get userRole => _userRole;

  void setUserContext({required String userId, required String role}) {
    _currentUserId = userId;
    _userRole = role;
    notifyListeners();
  }

  void _initStream() {
    _isLoading = true;
    _subscription?.cancel();
    _subscription = _service.getJobsStream().listen((jobsList) {
      _jobs = List.from(jobsList);
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void setCategoryFilter(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Filter jobs by selected category and search query
  List<MarketJob> _applyFilter(List<MarketJob> sourceList) {
    return sourceList.where((job) {
      final matchesCategory = _selectedCategory == 'الكل' || job.serviceType == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          job.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.location.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<MarketJob> get filteredAllJobs => _applyFilter(_jobs);

  List<MarketJob> get nearbyJobs => _applyFilter(
        _jobs.where((j) => j.distance <= 5.0).toList()
          ..sort((a, b) => a.distance.compareTo(b.distance)),
      );

  List<MarketJob> get urgentJobs => _applyFilter(
        _jobs.where((j) => j.isUrgent).toList(),
      );

  List<MarketJob> get myPostedJobs => _jobs.where((j) => j.clientId == _currentUserId).toList();

  List<MarketJob> get mySubmittedOffers => _jobs.where((j) {
        return j.bids.any((b) => b.technicianId == _currentUserId);
      }).toList();

  /// Post a new job
  Future<MarketJob> postJob({
    required String title,
    required String description,
    required String serviceType,
    required String location,
    required double price,
    String? clientId,
    String? clientName,
    bool isUrgent = false,
  }) async {
    final cId = clientId ?? _currentUserId ?? 'client_me';
    final cName = clientName ?? 'أنا (العميل)';

    final newJob = await _service.postJob(
      title: title,
      description: description,
      serviceType: serviceType,
      location: location,
      price: price,
      clientId: cId,
      clientName: cName,
      isUrgent: isUrgent,
    );

    // If offline / local stream didn't auto-update:
    if (!_jobs.any((j) => j.id == newJob.id)) {
      _jobs.insert(0, newJob);
      notifyListeners();
    }

    return newJob;
  }

  /// Submit a bid / offer
  Future<void> submitBid({
    required String jobId,
    required double proposedPrice,
    required String arrivalTime,
    required String notes,
    String? techId,
    String? techName,
    double technicianRating = 4.9,
  }) async {
    final tId = techId ?? _currentUserId ?? 'tech_me';
    final tName = techName ?? 'م. كريم سامي';

    await _service.submitBid(
      jobId: jobId,
      technicianId: tId,
      technicianName: tName,
      proposedPrice: proposedPrice,
      arrivalTime: arrivalTime,
      notes: notes,
      technicianRating: technicianRating,
    );

    final idx = _jobs.indexWhere((j) => j.id == jobId);
    if (idx != -1) {
      final newBid = JobBid(
        id: 'bid_${DateTime.now().millisecondsSinceEpoch}',
        jobId: jobId,
        technicianId: tId,
        technicianName: tName,
        technicianRating: technicianRating,
        proposedPrice: proposedPrice,
        arrivalTime: arrivalTime,
        notes: notes,
        createdAt: DateTime.now(),
        status: BidStatus.pending,
      );
      final updatedBids = List<JobBid>.from(_jobs[idx].bids)..add(newBid);
      _jobs[idx] = _jobs[idx].copyWith(bids: updatedBids);
      notifyListeners();
    }
  }

  /// Accept a bid
  Future<void> acceptBid({
    required String jobId,
    required String bidId,
  }) async {
    await _service.acceptBid(jobId: jobId, bidId: bidId);

    final idx = _jobs.indexWhere((j) => j.id == jobId);
    if (idx != -1) {
      String? acceptedTechId;
      final updatedBids = _jobs[idx].bids.map((b) {
        if (b.id == bidId) {
          acceptedTechId = b.technicianId;
          return b.copyWith(status: BidStatus.accepted);
        } else {
          return b.copyWith(status: BidStatus.rejected);
        }
      }).toList();

      _jobs[idx] = _jobs[idx].copyWith(
        status: 'assigned',
        assignedTechId: acceptedTechId,
        bids: updatedBids,
      );
      notifyListeners();
    }
  }

  /// Counter-offer on a bid
  Future<void> counterOffer({
    required String jobId,
    required String bidId,
    required double counterPrice,
    required String counterNotes,
  }) async {
    await _service.counterOffer(
      jobId: jobId,
      bidId: bidId,
      counterPrice: counterPrice,
      counterNotes: counterNotes,
    );

    final idx = _jobs.indexWhere((j) => j.id == jobId);
    if (idx != -1) {
      final updatedBids = _jobs[idx].bids.map((b) {
        if (b.id == bidId) {
          return b.copyWith(
            status: BidStatus.counterOffered,
            counterPrice: counterPrice,
            counterNotes: counterNotes,
          );
        }
        return b;
      }).toList();

      _jobs[idx] = _jobs[idx].copyWith(bids: updatedBids);
      notifyListeners();
    }
  }
}
