import 'package:flutter/material.dart';

class LoyaltyProvider extends ChangeNotifier {
  int _points = 350;
  int _level = 2;
  String _levelName = 'فضي';
  
  int get points => _points;
  int get level => _level;
  String get levelName => _levelName;
  
  double get nextLevelProgress => (_points % 1000) / 1000;
  int get pointsToNextLevel => 1000 - (_points % 1000);

  void addPoints(int amount) {
    _points += amount;
    _updateLevel();
    notifyListeners();
  }

  void _updateLevel() {
    if (_points >= 5000) {
      _level = 3;
      _levelName = 'ذهبي';
    } else if (_points >= 1000) {
      _level = 2;
      _levelName = 'فضي';
    } else {
      _level = 1;
      _levelName = 'برونزي';
    }
  }
}
