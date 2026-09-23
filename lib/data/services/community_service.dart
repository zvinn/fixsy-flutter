import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/app_logger.dart';
import '../models/community_question_model.dart';

class CommunityService {
  CommunityService({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  FirebaseFirestore? get _instance {
    if (_firestore != null) return _firestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  CollectionReference? get _questionsRef => _instance?.collection('community_questions');

  static final List<CommunityTip> curatedTips = [
    CommunityTip(
      title: 'تنظيف الفلاتر',
      body: 'قم بتنظيف فلاتر التكييف مرة كل شهر لتقليل استهلاك الكهرباء بنسبة 15% وتحسين جودة الهواء.',
      date: 'اليوم',
      likes: 42,
      category: 'تكييف',
    ),
    CommunityTip(
      title: 'صنبور المياه والتسريب',
      body: 'تأكد من إغلاق صنابير المياه جيداً، فالتنقيط المستمر يهدر أكثر من 300 لتر مياه شهرياً.',
      date: 'اليوم',
      likes: 38,
      category: 'سباكة',
    ),
    CommunityTip(
      title: 'كفاءة الثلاجة',
      body: 'لا تضع الأطعمة الساخنة مباشرة في الثلاجة، انتظر حتى تبرد تماماً لتوفير الطاقة وحماية الموتور.',
      date: 'اليوم',
      likes: 29,
      category: 'أجهزة كهربائية',
    ),
    CommunityTip(
      title: 'فحص القواطع الكهربائية',
      body: 'اختبر زر الاختبار (Test) لقاطع الأمان مرة كل 3 أشهر للتأكد من حماية منزلك من الصدمات.',
      date: 'اليوم',
      likes: 51,
      category: 'كهرباء',
    ),
  ];

  static List<CommunityQuestion> getFallbackQuestions() {
    return [
      CommunityQuestion(
        id: 'mock_q1',
        question: 'عندي تسريب مياه بسيط تحت حوض المطبخ، هل ممكن أصلحه بنفسي ولا محتاج سباك ضروري؟',
        authorName: 'أحمد محمود',
        date: DateTime.now().subtract(const Duration(hours: 3)),
        likes: 12,
        answers: [
          CommunityAnswer(
            text: 'غالباً الجوان محتاج تغيير أو ربط صامولة الصرف بالمفتاح الإنجليزي بلطف بدون كسرها.',
            authorName: 'م/ عصام السباك',
            date: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          CommunityAnswer(
            text: 'حط شريط تفلون أبيض على السن وجرب قبل ما تجيب سباك.',
            authorName: 'طارق علي',
            date: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ],
      ),
      CommunityQuestion(
        id: 'mock_q2',
        question: 'التكييف بيطلع هوا دافي ومش بيبرد كويس، ايه أول حاجة أفحصها؟',
        authorName: 'سارة إبراهيم',
        date: DateTime.now().subtract(const Duration(days: 1)),
        likes: 19,
        answers: [
          CommunityAnswer(
            text: 'أول حاجة نظفي الفلاتر الداخلية، لو فضلت المشكلة يبقى فريون أو محتاج غسيل الوحدة الخارجية.',
            authorName: 'فني تكييف معتمد',
            date: DateTime.now().subtract(const Duration(hours: 18)),
          ),
        ],
      ),
      CommunityQuestion(
        id: 'mock_q3',
        question: 'لو النور قطع فجأة في أوضة واحدة بس وباقي الشقة شغالة، ايه الحل؟',
        authorName: 'محمد سامي',
        date: DateTime.now().subtract(const Duration(days: 2)),
        likes: 8,
        answers: [
          CommunityAnswer(
            text: 'افحص لوحة الكهرباء الرئيسية وشوف القاطع الصغير الخاص بالغرفة دي نزل ولا لأ، ارفعه بعد فصل أي جهاز زيادة.',
            authorName: 'عمرو فني كهرباء',
            date: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
    ];
  }

  /// Stream questions in real-time
  Stream<List<CommunityQuestion>> streamQuestions() {
    final ref = _questionsRef;
    if (ref == null) {
      return Stream.value(getFallbackQuestions());
    }

    try {
      return ref.snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return getFallbackQuestions();
        }
        final list = snapshot.docs
            .map((doc) => CommunityQuestion.fromFirestore(doc))
            .toList();
        list.sort((a, b) => b.date.compareTo(a.date));
        return list;
      }).handleError((error) {
        AppLogger.error('Failed to stream community questions', error: error);
        return getFallbackQuestions();
      });
    } catch (e) {
      AppLogger.error('Error in streamQuestions', error: e);
      return Stream.value(getFallbackQuestions());
    }
  }

  /// Post a new question
  Future<CommunityQuestion> addQuestion({
    required String question,
    required String authorName,
    String? authorEmail,
    String? authorPhoto,
  }) async {
    final ref = _questionsRef;
    final docId = ref != null ? ref.doc().id : DateTime.now().millisecondsSinceEpoch.toString();

    final item = CommunityQuestion(
      id: docId,
      question: question,
      authorName: authorName,
      authorEmail: authorEmail,
      authorPhoto: authorPhoto,
      date: DateTime.now(),
      answers: [],
      likes: 0,
    );

    if (ref != null) {
      try {
        await ref.doc(docId).set(item.toJson());
        AppLogger.info('Question posted successfully: $docId');
      } catch (e) {
        AppLogger.warn('Failed to save question to Firestore: $e');
      }
    }

    return item;
  }

  /// Add an answer to a question
  Future<bool> addAnswer({
    required String questionId,
    required String text,
    required String authorName,
    String? authorPhoto,
  }) async {
    final ref = _questionsRef;
    final answer = CommunityAnswer(
      text: text,
      authorName: authorName,
      authorPhoto: authorPhoto,
      date: DateTime.now(),
    );

    if (ref != null) {
      try {
        await ref.doc(questionId).update({
          'answers': FieldValue.arrayUnion([answer.toJson()]),
        });
        AppLogger.info('Answer added to question: $questionId');
        return true;
      } catch (e) {
        AppLogger.warn('Failed to add answer in Firestore: $e');
      }
    }
    return true;
  }

  /// Like a question
  Future<void> likeQuestion(String questionId) async {
    final ref = _questionsRef;
    if (ref != null) {
      try {
        await ref.doc(questionId).update({
          'likes': FieldValue.increment(1),
        });
      } catch (e) {
        AppLogger.warn('Failed to like question: $e');
      }
    }
  }
}
