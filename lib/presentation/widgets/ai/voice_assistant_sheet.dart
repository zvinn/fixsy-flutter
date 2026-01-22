import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../../../core/theme/app_theme.dart';

class VoiceAssistantSheet extends StatefulWidget {
  const VoiceAssistantSheet({super.key});

  @override
  State<VoiceAssistantSheet> createState() => _VoiceAssistantSheetState();
}

class _VoiceAssistantSheetState extends State<VoiceAssistantSheet> {
  bool _isListening = false;
  String _text = 'اضغط للتحدث...';

  void _toggleListening() async {
    setState(() {
      _isListening = !_isListening;
      _text = _isListening ? 'أستمع إليك...' : 'اضغط للتحدث...';
    });

    if (_isListening) {
      // Simulate processing
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          _isListening = false;
          _text = 'جاري البحث عن "سباك في المعادي"...';
        });
        
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
           Navigator.pop(context);
           // Here we would navigate to search results
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('تم العثور على 5 سباكين في منطقتك')),
           );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          
          Text(
            'مساعد Fixsy الذكي',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _text,
            style: TextStyle(
              fontSize: 18,
              color: _isListening ? AppTheme.secondaryColor : Colors.grey.shade600,
            ),
          ).animate(target: _isListening ? 1 : 0).fade(end: 0.5).scale(),
          
          const SizedBox(height: 48),
          
          AvatarGlow(
            animate: _isListening,
            glowColor: AppTheme.primaryColor,
            duration: const Duration(milliseconds: 2000),
            repeat: true,
            startDelay: const Duration(milliseconds: 100),
            child: GestureDetector(
              onTap: _toggleListening,
              child: CircleAvatar(
                backgroundColor: _isListening ? Colors.red : AppTheme.primaryColor,
                radius: 40,
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 48),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildSuggestionChip('أحتاج كهربائي'),
              _buildSuggestionChip('تنظيف تكييف'),
              _buildSuggestionChip('أسعار الصيانة'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        setState(() {
          _text = 'جاري البحث عن "$label"...';
          _isListening = true;
        });
        _toggleListening(); // Reset/Start logic
      },
      backgroundColor: Colors.grey.shade100,
      labelStyle: const TextStyle(color: Colors.black87),
    );
  }
}
