import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/l10n/app_localizations.dart';

class VoiceRecorderWidget extends StatefulWidget {
  final Function(String path, Duration duration) onStop;

  const VoiceRecorderWidget({super.key, required this.onStop});

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  late AnimationController _animationController;
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _seconds = 0;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _seconds++);
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    setState(() => _isRecording = false);
    
    // Simulate a recorded file path
    widget.onStop('path/to/audio.m4a', Duration(seconds: _seconds));
  }

  String _formatDuration(int seconds) {
    final m = (seconds / 60).floor().toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopRecording(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _isRecording ? Colors.red : AppTheme.primaryColor,
          shape: BoxShape.circle,
          boxShadow: _isRecording 
              ? [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)] 
              : null,
        ),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _isRecording ? 1.0 + (_animationController.value * 0.2) : 1.0,
              child: child,
            );
          },
          child: _isRecording
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.mic, color: Colors.white),
                    if (_isRecording) ...[
                      const SizedBox(width: 8),
                      Material(
                        color: Colors.transparent,
                        child: Text(
                          _formatDuration(_seconds),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                )
              : const Icon(Icons.mic, color: Colors.white),
        ),
      ),
    );
  }
}
