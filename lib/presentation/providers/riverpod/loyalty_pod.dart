import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoyaltyState {

  LoyaltyState({
    required this.points,
    required this.level,
    required this.levelName,
  });

  factory LoyaltyState.initial() {
    return LoyaltyState(points: 350, level: 2, levelName: 'فضي');
  }
  final int points;
  final int level;
  final String levelName;

  LoyaltyState copyWith({int? points, int? level, String? levelName}) {
    return LoyaltyState(
      points: points ?? this.points,
      level: level ?? this.level,
      levelName: levelName ?? this.levelName,
    );
  }

  double get nextLevelProgress => (points % 1000) / 1000;
  int get pointsToNextLevel => 1000 - (points % 1000);
}

class LoyaltyNotifier extends StateNotifier<LoyaltyState> {
  LoyaltyNotifier() : super(LoyaltyState.initial());

  void addPoints(int amount) {
    final newPoints = state.points + amount;
    var newLevel = state.level;
    var newLevelName = state.levelName;

    if (newPoints >= 5000) {
      newLevel = 3;
      newLevelName = 'ذهبي';
    } else if (newPoints >= 1000) {
      newLevel = 2;
      newLevelName = 'فضي';
    } else {
      newLevel = 1;
      newLevelName = 'برونزي';
    }

    state = state.copyWith(
      points: newPoints,
      level: newLevel,
      levelName: newLevelName,
    );
  }
}

// The global provider
final loyaltyProvider = StateNotifierProvider<LoyaltyNotifier, LoyaltyState>((ref) {
  return LoyaltyNotifier();
});
