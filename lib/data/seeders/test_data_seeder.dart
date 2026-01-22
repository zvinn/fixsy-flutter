import 'package:cloud_firestore/cloud_firestore.dart';

/// Script to add test data to Firebase
/// Run this once to populate your Firestore with sample services and bookings
class TestDataSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedData() async {
    print('🌱 Starting to seed test data...');
    
    await _seedServices();
    print('✅ Services added successfully!');
    
    print('🎉 Test data seeding completed!');
  }

  Future<void> _seedServices() async {
    final services = [
      {
        'name': 'صيانة مكيفات',
        'description': 'خدمة صيانة وتنظيف المكيفات الهوائية بجميع أنواعها',
        'category': 'تكييف',
        'price': 150.0,
        'imageUrl': 'https://via.placeholder.com/400x300/4F46E5/FFFFFF?text=AC+Service',
        'isActive': true,
        'rating': 4.5,
        'reviewCount': 120,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'إصلاح سباكة',
        'description': 'إصلاح جميع مشاكل السباكة والتسريبات',
        'category': 'سباكة',
        'price': 200.0,
        'imageUrl': 'https://via.placeholder.com/400x300/10B981/FFFFFF?text=Plumbing',
        'isActive': true,
        'rating': 4.7,
        'reviewCount': 89,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'صيانة كهرباء',
        'description': 'فحص وإصلاح الأعطال الكهربائية المنزلية',
        'category': 'كهرباء',
        'price': 180.0,
        'imageUrl': 'https://via.placeholder.com/400x300/F59E0B/FFFFFF?text=Electrical',
        'isActive': true,
        'rating': 4.6,
        'reviewCount': 145,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'دهان وديكور',
        'description': 'خدمات الدهان والديكور للمنازل والشقق',
        'category': 'دهان',
        'price': 300.0,
        'imageUrl': 'https://via.placeholder.com/400x300/EF4444/FFFFFF?text=Painting',
        'isActive': true,
        'rating': 4.8,
        'reviewCount': 67,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'نظافة عامة',
        'description': 'خدمة تنظيف شاملة للمنزل',
        'category': 'نظافة',
        'price': 120.0,
        'imageUrl': 'https://via.placeholder.com/400x300/8B5CF6/FFFFFF?text=Cleaning',
        'isActive': true,
        'rating': 4.9,
        'reviewCount': 234,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'صيانة أجهزة منزلية',
        'description': 'إصلاح الثلاجات والغسالات والأفران',
        'category': 'أجهزة',
        'price': 250.0,
        'imageUrl': 'https://via.placeholder.com/400x300/06B6D4/FFFFFF?text=Appliances',
        'isActive': true,
        'rating': 4.4,
        'reviewCount': 98,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'تركيب نجف وإضاءة',
        'description': 'تركيب وصيانة الإضاءة والنجف',
        'category': 'كهرباء',
        'price': 100.0,
        'imageUrl': 'https://via.placeholder.com/400x300/EC4899/FFFFFF?text=Lighting',
        'isActive': true,
        'rating': 4.3,
        'reviewCount': 56,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'مكافحة حشرات',
        'description': 'خدمة مكافحة الحشرات والقوارض',
        'category': 'نظافة',
        'price': 220.0,
        'imageUrl': 'https://via.placeholder.com/400x300/14B8A6/FFFFFF?text=Pest+Control',
        'isActive': true,
        'rating': 4.7,
        'reviewCount': 112,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    final batch = _firestore.batch();
    
    for (var service in services) {
      final docRef = _firestore.collection('services').doc();
      batch.set(docRef, service);
    }

    await batch.commit();
  }
}

// To run this seeder:
// 1. Create a test user first (register in the app)
// 2. Call TestDataSeeder().seedData() from your app
// 3. Or create a button in your app that calls this
