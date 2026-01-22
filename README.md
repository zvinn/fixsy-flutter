# Fixsy Flutter 🛠️

تطبيق خدمات الصيانة المنزلية - Flutter

## 📱 نظرة عامة

Fixsy هو تطبيق يربط بين العملاء والفنيين المحترفين لخدمات الصيانة المنزلية في مصر.

## ✨ المميزات

### للعملاء
- 🔍 البحث عن خدمات الصيانة
- 📅 حجز المواعيد
- 📍 تتبع الفني على الخريطة
- ⭐ تقييم الخدمة
- 💬 الدردشة مع الفني
- 💰 الدفع الإلكتروني

### للفنيين
- 📋 استلام الطلبات
- 📊 لوحة تحكم الأرباح
- 🔔 إشعارات فورية
- 💼 سوق العمل

### للمدراء
- 📈 إحصائيات شاملة
- 👥 إدارة المستخدمين
- ✅ قبول الفنيين الجدد

## 🚀 البدء السريع

### المتطلبات
```
Flutter 3.10.4+
Dart 3.0+
Firebase Project
```

### التثبيت
```bash
# استنساخ المشروع
git clone <repo-url>
cd fixsy_flutter

# تثبيت الحزم
flutter pub get

# تشغيل التطبيق
flutter run
```

### ملف البيئة (.env)
```env
GROQ_API_KEY=your_api_key
```

## 📂 هيكل المشروع

```
lib/
├── core/
│   ├── config/
│   ├── theme/
│   └── utils/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── presentation/
│   ├── screens/
│   └── widgets/
└── routes/
```

## 🧪 الاختبارات

```bash
# تشغيل جميع الاختبارات
flutter test

# اختبارات وحدة
flutter test test/unit

# اختبارات Widget
flutter test test/widget
```

## 📦 الحزم المستخدمة

| الحزمة | الاستخدام |
|--------|----------|
| firebase_core | Firebase |
| firebase_auth | المصادقة |
| cloud_firestore | قاعدة البيانات |
| google_maps_flutter | الخرائط |
| provider | إدارة الحالة |
| flutter_animate | الحركات |

## 🔗 المسارات

| المسار | الشاشة |
|--------|--------|
| `/` | Home |
| `/login` | تسجيل الدخول |
| `/profile` | الملف الشخصي |
| `/bookings` | الحجوزات |
| `/community` | المجتمع |
| `/job-market` | سوق العمل |
| `/admin` | لوحة التحكم |

## 🤝 المساهمة

1. Fork المشروع
2. أنشئ branch جديد
3. قم بالتعديلات
4. افتح Pull Request

## 📄 الرخصة

MIT License
