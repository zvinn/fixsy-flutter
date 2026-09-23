import 'package:flutter_test/flutter_test.dart';
import 'package:fixsy_flutter/presentation/providers/community_provider.dart';

void main() {
  group('CommunityProvider Unit Tests', () {
    late CommunityProvider provider;

    setUp(() {
      provider = CommunityProvider();
    });

    test('initializes with fallback questions and curated daily tip', () {
      expect(provider.questions.isNotEmpty, true);
      expect(provider.dailyTip.title.isNotEmpty, true);
      expect(provider.dailyTip.body.isNotEmpty, true);
    });

    test('likeDailyTip increments tip likes', () {
      final initialLikes = provider.dailyTip.likes;
      provider.likeDailyTip();
      expect(provider.dailyTip.likes, equals(initialLikes + 1));
      expect(provider.dailyTip.liked, isTrue);
    });

    test('nextDailyTip rotates through curated tips', () {
      final firstTitle = provider.dailyTip.title;
      provider.nextDailyTip();
      final secondTitle = provider.dailyTip.title;
      expect(secondTitle, isNot(equals(firstTitle)));
    });

    test('addQuestion adds new question to top of the list', () async {
      final initialCount = provider.questions.length;
      const questionText = 'هل من الممكن دهان الجدار فوق الدهان القديم مباشرة؟';
      const author = 'محمود سعيد';

      final q = await provider.addQuestion(
        question: questionText,
        authorName: author,
      );

      expect(provider.questions.length, equals(initialCount + 1));
      expect(provider.questions.first.id, equals(q.id));
      expect(provider.questions.first.question, equals(questionText));
      expect(provider.questions.first.authorName, equals(author));
    });

    test('addAnswer appends answer to specific question', () async {
      final targetQ = provider.questions.first;
      final initialAnswerCount = targetQ.answers.length;

      const answerText = 'نعم ولكن يجب صنفرة الجدار وتنظيفه من الأتربة أولاً.';
      const author = 'فني الدهانات';

      final success = await provider.addAnswer(
        questionId: targetQ.id,
        text: answerText,
        authorName: author,
      );

      expect(success, isTrue);
      final updatedQ = provider.questions.firstWhere((q) => q.id == targetQ.id);
      expect(updatedQ.answers.length, equals(initialAnswerCount + 1));
      expect(updatedQ.answers.last.text, equals(answerText));
    });

    test('likeQuestion increments question likes', () async {
      final targetQ = provider.questions.first;
      final initialLikes = targetQ.likes;

      await provider.likeQuestion(targetQ.id);

      final updatedQ = provider.questions.firstWhere((q) => q.id == targetQ.id);
      expect(updatedQ.likes, equals(initialLikes + 1));
      expect(updatedQ.liked, isTrue);
    });

    test('generateAiTip returns actionable DIY repair tip', () async {
      final tip = await provider.generateAiTip('تسريب مياه الحنفية');
      expect(tip.isNotEmpty, isTrue);
      expect(provider.aiGeneratedTip, equals(tip));
      expect(provider.isGeneratingAiTip, isFalse);
    });
  });
}
