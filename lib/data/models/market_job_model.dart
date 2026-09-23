enum BidStatus { pending, accepted, rejected, counterOffered }

/// Job Bid Model for negotiations and proposals
class JobBid {
  const JobBid({
    required this.id,
    required this.jobId,
    required this.technicianId,
    required this.technicianName,
    required this.proposedPrice,
    required this.arrivalTime,
    required this.notes,
    required this.createdAt,
    this.technicianRating = 4.9,
    this.technicianAvatar,
    this.status = BidStatus.pending,
    this.counterPrice,
    this.counterNotes,
  });

  factory JobBid.fromJson(Map<String, dynamic> json) {
    var parsedStatus = BidStatus.pending;
    try {
      final s = json['status']?.toString();
      if (s != null) {
        parsedStatus = BidStatus.values.firstWhere(
          (e) => e.name == s,
          orElse: () => BidStatus.pending,
        );
      }
    } catch (_) {}

    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['createdAt'].toString());
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return JobBid(
      id: json['id']?.toString() ?? '',
      jobId: json['jobId']?.toString() ?? '',
      technicianId: json['technicianId']?.toString() ?? '',
      technicianName: json['technicianName']?.toString() ?? 'فني معتمد',
      technicianRating: (json['technicianRating'] as num?)?.toDouble() ?? 4.9,
      technicianAvatar: json['technicianAvatar']?.toString(),
      proposedPrice: (json['proposedPrice'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble() ?? 0.0,
      arrivalTime: json['arrivalTime']?.toString() ?? 'خلال ساعة',
      notes: json['notes']?.toString() ?? json['note']?.toString() ?? '',
      createdAt: parsedDate,
      status: parsedStatus,
      counterPrice: (json['counterPrice'] as num?)?.toDouble(),
      counterNotes: json['counterNotes']?.toString(),
    );
  }

  final String id;
  final String jobId;
  final String technicianId;
  final String technicianName;
  final double technicianRating;
  final String? technicianAvatar;
  final double proposedPrice;
  final String arrivalTime;
  final String notes;
  final DateTime createdAt;
  final BidStatus status;
  final double? counterPrice;
  final String? counterNotes;

  JobBid copyWith({
    String? id,
    String? jobId,
    String? technicianId,
    String? technicianName,
    double? technicianRating,
    String? technicianAvatar,
    double? proposedPrice,
    String? arrivalTime,
    String? notes,
    DateTime? createdAt,
    BidStatus? status,
    double? counterPrice,
    String? counterNotes,
  }) {
    return JobBid(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      technicianId: technicianId ?? this.technicianId,
      technicianName: technicianName ?? this.technicianName,
      technicianRating: technicianRating ?? this.technicianRating,
      technicianAvatar: technicianAvatar ?? this.technicianAvatar,
      proposedPrice: proposedPrice ?? this.proposedPrice,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      counterPrice: counterPrice ?? this.counterPrice,
      counterNotes: counterNotes ?? this.counterNotes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'technicianId': technicianId,
      'technicianName': technicianName,
      'technicianRating': technicianRating,
      'technicianAvatar': technicianAvatar,
      'proposedPrice': proposedPrice,
      'arrivalTime': arrivalTime,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'counterPrice': counterPrice,
      'counterNotes': counterNotes,
    };
  }
}

/// Market Job Model
class MarketJob {
  const MarketJob({
    required this.id,
    required this.title,
    required this.description,
    required this.serviceType,
    required this.location,
    required this.price,
    required this.createdAt,
    required this.clientName,
    this.distance = 2.5,
    this.clientId = 'client_1',
    this.clientPhoto,
    this.isUrgent = false,
    this.status = 'open',
    this.assignedTechId,
    this.bids = const [],
  });

  factory MarketJob.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse((json['createdAt'] ?? json['date']).toString());
    } catch (_) {
      parsedDate = DateTime.now();
    }

    var parsedBids = <JobBid>[];
    final rawBids = json['bids'] ?? json['offers'];
    if (rawBids is List) {
      parsedBids = rawBids
          .whereType<Map<String, dynamic>>()
          .map((b) => JobBid.fromJson(b))
          .toList();
    }

    return MarketJob(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? json['desc']?.toString() ?? '',
      serviceType: json['serviceType']?.toString() ?? json['category']?.toString() ?? 'صيانة عامة',
      location: json['location']?.toString() ?? 'القاهرة، مصر',
      distance: (json['distance'] as num?)?.toDouble() ?? 2.5,
      price: (json['price'] as num?)?.toDouble() ?? (json['budget'] as num?)?.toDouble() ?? 0.0,
      createdAt: parsedDate,
      clientId: json['clientId']?.toString() ?? 'client_1',
      clientName: json['clientName']?.toString() ?? 'عميل Fixsy',
      clientPhoto: json['clientPhoto']?.toString(),
      isUrgent: json['isUrgent'] == true,
      status: json['status']?.toString() ?? 'open',
      assignedTechId: json['assignedTechId']?.toString(),
      bids: parsedBids,
    );
  }

  final String id;
  final String title;
  final String description;
  final String serviceType;
  final String location;
  final double distance;
  final double price; // Budget
  final DateTime createdAt;
  final String clientId;
  final String clientName;
  final String? clientPhoto;
  final bool isUrgent;
  final String status; // 'open', 'assigned', 'completed', 'cancelled'
  final String? assignedTechId;
  final List<JobBid> bids;

  MarketJob copyWith({
    String? id,
    String? title,
    String? description,
    String? serviceType,
    String? location,
    double? distance,
    double? price,
    DateTime? createdAt,
    String? clientId,
    String? clientName,
    String? clientPhoto,
    bool? isUrgent,
    String? status,
    String? assignedTechId,
    List<JobBid>? bids,
  }) {
    return MarketJob(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      serviceType: serviceType ?? this.serviceType,
      location: location ?? this.location,
      distance: distance ?? this.distance,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientPhoto: clientPhoto ?? this.clientPhoto,
      isUrgent: isUrgent ?? this.isUrgent,
      status: status ?? this.status,
      assignedTechId: assignedTechId ?? this.assignedTechId,
      bids: bids ?? this.bids,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'serviceType': serviceType,
      'location': location,
      'distance': distance,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
      'clientId': clientId,
      'clientName': clientName,
      'clientPhoto': clientPhoto,
      'isUrgent': isUrgent,
      'status': status,
      'assignedTechId': assignedTechId,
      'bids': bids.map((b) => b.toJson()).toList(),
    };
  }
}

/// Backward compatibility typedef
typedef Job = MarketJob;
