class AiDiagnosis {
  final String problem;
  final String suggestedService;
  final String solution;
  final double estimatedPrice;
  final String confidence;

  AiDiagnosis({
    required this.problem,
    required this.suggestedService,
    required this.solution,
    required this.estimatedPrice,
    required this.confidence,
  });

  factory AiDiagnosis.fromJson(Map<String, dynamic> json) {
    return AiDiagnosis(
      problem: json['problem'] ?? '',
      suggestedService: json['suggestedService'] ?? '',
      solution: json['solution'] ?? '',
      estimatedPrice: (json['estimatedPrice'] ?? 0).toDouble(),
      confidence: json['confidence'] ?? 'متوسط',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'problem': problem,
      'suggestedService': suggestedService,
      'solution': solution,
      'estimatedPrice': estimatedPrice,
      'confidence': confidence,
    };
  }
}
