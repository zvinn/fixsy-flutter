import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/community_question_model.dart';
import '../../data/services/community_service.dart';
import '../../data/services/ai_service.dart';

class CommunityProvider extends ChangeNotifier {
  CommunityProvider({
    CommunityService? communityService,
    AiService? aiService,
  })  : _communityService = communityService ?? CommunityService(),
        _aiService = aiService ?? AiService() {
    _init();
  }

  final CommunityService _communityService;
  final AiService _aiService;

  List<CommunityQuestion> _questions = [];
  CommunityTip _dailyTip = CommunityService.curatedTips[0];
  int _currentTipIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<CommunityQuestion>>? _subscription;

  // AI DIY advice state
  bool _isGeneratingAiTip = false;
  String? _aiGeneratedTip;

  List<CommunityQuestion> get questions => _questions;
  CommunityTip get dailyTip => _dailyTip;
  bool get isLoading => _isLoading;
  bool get isGeneratingAiTip => _isGeneratingAiTip;
  String? get aiGeneratedTip => _aiGeneratedTip;
  String? get errorMessage => _errorMessage;

  void _init() {
    _isLoading = true;
    _questions = CommunityService.getFallbackQuestions();
    notifyListeners();

    _subscription = _communityService.streamQuestions().listen(
      (data) {
        _questions = data;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (err) {
        _errorMessage = err.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Add new question
  Future<CommunityQuestion> addQuestion({
    required String question,
    required String authorName,
    String? authorEmail,
    String? authorPhoto,
  }) async {
    final item = await _communityService.addQuestion(
      question: question,
      authorName: authorName,
      authorEmail: authorEmail,
      authorPhoto: authorPhoto,
    );
    _questions.insert(0, item);
    notifyListeners();
    return item;
  }

  /// Add answer to question
  Future<bool> addAnswer({
    required String questionId,
    required String text,
    required String authorName,
    String? authorPhoto,
  }) async {
    final success = await _communityService.addAnswer(
      questionId: questionId,
      text: text,
      authorName: authorName,
      authorPhoto: authorPhoto,
    );

    final idx = _questions.indexWhere((q) => q.id == questionId);
    if (idx != -1) {
      final updatedAnswers = List<CommunityAnswer>.from(_questions[idx].answers)
        ..add(CommunityAnswer(
          text: text,
          authorName: authorName,
          authorPhoto: authorPhoto,
          date: DateTime.now(),
        ));
      _questions[idx] = _questions[idx].copyWith(answers: updatedAnswers);
      notifyListeners();
    }
    return success;
  }

  /// Like a question
  Future<void> likeQuestion(String questionId) async {
    final idx = _questions.indexWhere((q) => q.id == questionId);
    if (idx != -1 && !_questions[idx].liked) {
      _questions[idx] = _questions[idx].copyWith(
        likes: _questions[idx].likes + 1,
        liked: true,
      );
      notifyListeners();
      await _communityService.likeQuestion(questionId);
    }
  }

  /// Like daily tip
  void likeDailyTip() {
    if (!_dailyTip.liked) {
      _dailyTip = _dailyTip.copyWith(
        likes: _dailyTip.likes + 1,
        liked: true,
      );
      notifyListeners();
    }
  }

  /// Rotate to next tip
  void nextDailyTip() {
    _currentTipIndex = (_currentTipIndex + 1) % CommunityService.curatedTips.length;
    _dailyTip = CommunityService.curatedTips[_currentTipIndex];
    notifyListeners();
  }

  /// Generate AI DIY Advice
  Future<String> generateAiTip(String topic) async {
    _isGeneratingAiTip = true;
    _aiGeneratedTip = null;
    notifyListeners();

    try {
      final diagnosis = await _aiService.analyzeProblem(
        images: [],
        description: topic,
      );
      _aiGeneratedTip = '${diagnosis.problem}\n\nالحل المقترح:\n${diagnosis.solution}\n\nنصائح السلامة:\n${diagnosis.advice ?? 'يرجى توخي الحذر عند التعامل مع الأجهزة والمعدات.'}';
    } catch (_) {
      _aiGeneratedTip = 'نصيحة سريعة لـ $topic:\n1. تأكد من فصل الكهرباء أو قفل محبس المياه أولاً لضمان السلامة.\n2. افحص الوصلات المرئية ونظف الرواسب أو الغبار.\n3. إذا استمرت المشكلة، استعن بفني Fixsy المعتمد لضمان الجودة.';
    } finally {
      _isGeneratingAiTip = false;
      notifyListeners();
    }
    return _aiGeneratedTip!;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
