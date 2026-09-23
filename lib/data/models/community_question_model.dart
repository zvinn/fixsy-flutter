import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityAnswer {
  CommunityAnswer({
    required this.text,
    required this.authorName,
    required this.date,
    this.authorPhoto,
  });

  factory CommunityAnswer.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    final rawDate = json['date'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return CommunityAnswer(
      text: json['text'] as String? ?? '',
      authorName: json['authorName'] as String? ?? 'مستخدم',
      authorPhoto: json['authorPhoto'] as String?,
      date: parsedDate,
    );
  }

  final String text;
  final String authorName;
  final String? authorPhoto;
  final DateTime date;

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'authorName': authorName,
      if (authorPhoto != null) 'authorPhoto': authorPhoto,
      'date': Timestamp.fromDate(date),
    };
  }
}

class CommunityTip {
  CommunityTip({
    required this.title,
    required this.body,
    required this.date,
    this.likes = 0,
    this.liked = false,
    this.category = 'عام',
  });

  factory CommunityTip.fromJson(Map<String, dynamic> json) {
    return CommunityTip(
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      date: json['date'] as String? ?? '',
      likes: json['likes'] as int? ?? 0,
      liked: json['liked'] as bool? ?? false,
      category: json['category'] as String? ?? 'عام',
    );
  }

  final String title;
  final String body;
  final String date;
  final int likes;
  final bool liked;
  final String category;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'date': date,
      'likes': likes,
      'liked': liked,
      'category': category,
    };
  }

  CommunityTip copyWith({
    String? title,
    String? body,
    String? date,
    int? likes,
    bool? liked,
    String? category,
  }) {
    return CommunityTip(
      title: title ?? this.title,
      body: body ?? this.body,
      date: date ?? this.date,
      likes: likes ?? this.likes,
      liked: liked ?? this.liked,
      category: category ?? this.category,
    );
  }
}

class CommunityQuestion {
  CommunityQuestion({
    required this.id,
    required this.question,
    required this.authorName,
    required this.date,
    this.authorEmail,
    this.authorPhoto,
    this.answers = const [],
    this.likes = 0,
    this.liked = false,
  });

  factory CommunityQuestion.fromJson(Map<String, dynamic> json, {String? id}) {
    DateTime parsedDate;
    final rawDate = json['date'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else if (rawDate is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(rawDate);
    } else {
      parsedDate = DateTime.now();
    }

    final rawAnswers = json['answers'] as List<dynamic>? ?? [];
    final parsedAnswers = rawAnswers
        .map((a) => CommunityAnswer.fromJson(Map<String, dynamic>.from(a as Map)))
        .toList();

    return CommunityQuestion(
      id: id ?? json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      authorName: json['authorName'] as String? ?? 'مستخدم فيكسي',
      authorEmail: json['authorEmail'] as String?,
      authorPhoto: json['authorPhoto'] as String?,
      date: parsedDate,
      answers: parsedAnswers,
      likes: json['likes'] as int? ?? 0,
      liked: json['liked'] as bool? ?? false,
    );
  }

  factory CommunityQuestion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CommunityQuestion.fromJson(data, id: doc.id);
  }

  final String id;
  final String question;
  final String authorName;
  final String? authorEmail;
  final String? authorPhoto;
  final DateTime date;
  final List<CommunityAnswer> answers;
  final int likes;
  final bool liked;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'authorName': authorName,
      if (authorEmail != null) 'authorEmail': authorEmail,
      if (authorPhoto != null) 'authorPhoto': authorPhoto,
      'date': Timestamp.fromDate(date),
      'answers': answers.map((a) => a.toJson()).toList(),
      'likes': likes,
    };
  }

  CommunityQuestion copyWith({
    String? id,
    String? question,
    String? authorName,
    String? authorEmail,
    String? authorPhoto,
    DateTime? date,
    List<CommunityAnswer>? answers,
    int? likes,
    bool? liked,
  }) {
    return CommunityQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      authorName: authorName ?? this.authorName,
      authorEmail: authorEmail ?? this.authorEmail,
      authorPhoto: authorPhoto ?? this.authorPhoto,
      date: date ?? this.date,
      answers: answers ?? this.answers,
      likes: likes ?? this.likes,
      liked: liked ?? this.liked,
    );
  }
}
