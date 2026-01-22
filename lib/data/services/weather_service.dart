import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/utils/app_logger.dart';

class WeatherAlert {
  final String title;
  final String description;
  final String severity; // low, medium, high
  final DateTime timestamp;

  WeatherAlert({
    required this.title,
    required this.description,
    required this.severity,
    required this.timestamp,
  });
}

class WeatherService {
  // Mock API for now
  static const String _baseUrl = 'https://api.weatherapi.com/v1'; 
  final String _apiKey = 'MOCK_KEY'; // Replace with env var

  Future<WeatherAlert?> checkWeatherAlerts(double lat, double lng) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Return a mock alert randomly for testing
      // In production, this would parse real API response
      /*
      final response = await http.get(Uri.parse('$_baseUrl/alerts.json?key=$_apiKey&q=$lat,$lng'));
      if (response.statusCode == 200) {
        // parse
      }
      */
      
      // Mock alert condition (e.g. if lat > 30)
      if (lat > 30.0) {
        return WeatherAlert(
          title: 'تحذير عاصفة رملية',
          description: 'يتوقع هبوب عواصف رملية قوية في منطقتك. يرجى تأمين النوافذ.',
          severity: 'high',
          timestamp: DateTime.now(),
        );
      }
      
      return null;
    } catch (e) {
      AppLogger.error('Error fetching weather alerts: $e');
      return null;
    }
  }
}
