import 'package:flutter/material.dart';

/// Star Rating Input Widget
/// Interactive star rating widget for user input
class StarRatingInput extends StatefulWidget {
  final double initialRating;
  final ValueChanged<double> onRatingChanged;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool allowHalfRating;

  const StarRatingInput({
    Key? key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.size = 40.0,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
    this.allowHalfRating = false,
  }) : super(key: key);

  @override
  State<StarRatingInput> createState() => _StarRatingInputState();
}

class _StarRatingInputState extends State<StarRatingInput> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = (index + 1).toDouble();
            });
            widget.onRatingChanged(_currentRating);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Icon(
              index < _currentRating.floor()
                  ? Icons.star
                  : (index < _currentRating ? Icons.star_half : Icons.star_border),
              color: index < _currentRating ? widget.activeColor : widget.inactiveColor,
              size: widget.size,
            ),
          ),
        );
      }),
    );
  }
}

/// Star Rating Display Widget
/// Read-only star rating display
class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool showRatingValue;
  final int? totalRatings;

  const StarRatingDisplay({
    Key? key,
    required this.rating,
    this.size = 20.0,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
    this.showRatingValue = true,
    this.totalRatings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < rating.floor()
                ? Icons.star
                : (index < rating ? Icons.star_half : Icons.star_border),
            color: index < rating ? activeColor : inactiveColor,
            size: size,
          );
        }),
        if (showRatingValue) ...[
          const SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.8,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
        if (totalRatings != null) ...[
          const SizedBox(width: 4),
          Text(
            '($totalRatings)',
            style: TextStyle(
              fontSize: size * 0.7,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }
}

/// Rating Summary Widget
/// Shows rating distribution with bars
class RatingDistributionWidget extends StatelessWidget {
  final Map<int, int> distribution;
  final int totalRatings;
  final double barHeight;

  const RatingDistributionWidget({
    Key? key,
    required this.distribution,
    required this.totalRatings,
    this.barHeight = 8.0,
  }) : super(key: key);

  double _getPercentage(int stars) {
    if (totalRatings == 0) return 0;
    final count = distribution[stars] ?? 0;
    return (count / totalRatings);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int stars = 5; stars >= 1; stars--)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                // Star label
                Row(
                  children: [
                    Text(
                      '$stars',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                  ],
                ),
                const SizedBox(width: 12),
                
                // Progress bar
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _getPercentage(stars),
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                      minHeight: barHeight,
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Count
                SizedBox(
                  width: 40,
                  child: Text(
                    '${distribution[stars] ?? 0}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
