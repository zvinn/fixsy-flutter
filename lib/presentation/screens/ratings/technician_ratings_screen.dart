import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/rating_model.dart';
import '../../providers/rating_provider.dart';
import '../../widgets/rating_widgets.dart';
import 'package:intl/intl.dart';

/// Technician Ratings Screen
/// Shows all ratings for a specific technician
class TechnicianRatingsScreen extends StatefulWidget {
  final String technicianId;
  final String technicianName;

  const TechnicianRatingsScreen({
    Key? key,
    required this.technicianId,
    required this.technicianName,
  }) : super(key: key);

  @override
  State<TechnicianRatingsScreen> createState() => _TechnicianRatingsScreenState();
}

class _TechnicianRatingsScreenState extends State<TechnicianRatingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RatingProvider>(context, listen: false)
          .loadTechnicianRatings(widget.technicianId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تقييمات ${widget.technicianName}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<RatingProvider>(
        builder: (context, ratingProvider, child) {
          if (ratingProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (ratingProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    ratingProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ratingProvider.loadTechnicianRatings(widget.technicianId);
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          final stats = ratingProvider.technicianStats;
          final ratings = ratingProvider.ratings;

          if (stats == null || stats.totalRatings == 0) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد تقييمات بعد',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Rating Summary Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            stats.averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12, right: 4),
                            child: Text(
                              '/ 5',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      StarRatingDisplay(
                        rating: stats.averageRating,
                        size: 28,
                        activeColor: Colors.amber,
                        inactiveColor: Colors.white30,
                        showRatingValue: false,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${stats.totalRatings} تقييم',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // Rating Distribution
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'توزيع التقييمات',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      RatingDistributionWidget(
                        distribution: stats.ratingDistribution,
                        totalRatings: stats.totalRatings,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Reviews List
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'التقييمات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: ratings.length,
                  itemBuilder: (context, index) {
                    return _RatingCard(rating: ratings[index]);
                  },
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Rating Card Widget
class _RatingCard extends StatelessWidget {
  final Rating rating;

  const _RatingCard({required this.rating});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy', 'ar');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // User Avatar
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  child: Text(
                    rating.userName?.substring(0, 1).toUpperCase() ?? 'ع',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // User name and rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rating.userName ?? 'عميل',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      StarRatingDisplay(
                        rating: rating.rating,
                        size: 16,
                        showRatingValue: false,
                      ),
                    ],
                  ),
                ),
                
                // Date
                Text(
                  dateFormat.format(rating.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            if (rating.comment != null && rating.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                rating.comment!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
