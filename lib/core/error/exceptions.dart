/// Custom Exception Classes for Fixsy Flutter
/// Provides specific exception types for better error handling

/// Base App Exception
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message';
}

/// Network Related Exceptions
class NetworkException extends AppException {
  NetworkException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);

  @override
  String toString() => 'NetworkException: $message';
}

class NoInternetException extends NetworkException {
  NoInternetException()
      : super('لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك.');
}

class TimeoutException extends NetworkException {
  TimeoutException()
      : super('انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.');
}

class ServerException extends NetworkException {
  ServerException([String message = 'خطأ في الخادم. يرجى المحاولة لاحقاً'])
      : super(message);
}

/// Authentication Exceptions
class AuthException extends AppException {
  AuthException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);

  @override
  String toString() => 'AuthException: $message';
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException()
      : super('البريد الإلكتروني أو كلمة المرور غير صحيحة');
}

class UserNotFoundException extends AuthException {
  UserNotFoundException()
      : super('المستخدم غير موجود');
}

class UserDisabledException extends AuthException {
  UserDisabledException()
      : super('تم تعطيل هذا الحساب. يرجى التواصل مع الدعم.');
}

class EmailAlreadyInUseException extends AuthException {
  EmailAlreadyInUseException()
      : super('البريد الإلكتروني مستخدم بالفعل');
}

class WeakPasswordException extends AuthException {
  WeakPasswordException()
      : super('كلمة المرور ضعيفة. يرجى استخدام كلمة مرور أقوى');
}

class SessionExpiredException extends AuthException {
  SessionExpiredException()
      : super('انتهت جلستك. يرجى تسجيل الدخول مرة أخرى.');
}

/// Validation Exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  ValidationException(String message, {this.fieldErrors, String? code})
      : super(message, code: code);

  @override
  String toString() => 'ValidationException: $message';
}

class InvalidEmailException extends ValidationException {
  InvalidEmailException()
      : super('البريد الإلكتروني غير صحيح');
}

class InvalidPhoneException extends ValidationException {
  InvalidPhoneException()
      : super('رقم الهاتف غير صحيح');
}

class EmptyFieldException extends ValidationException {
  final String fieldName;

  EmptyFieldException(this.fieldName)
      : super('$fieldName مطلوب');
}

/// Firestore Exceptions
class FirestoreException extends AppException {
  FirestoreException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);

  @override
  String toString() => 'FirestoreException: $message';
}

class DocumentNotFoundException extends FirestoreException {
  DocumentNotFoundException([String message = 'البيانات غير موجودة'])
      : super(message);
}

class PermissionDeniedException extends FirestoreException {
  PermissionDeniedException()
      : super('ليس لديك صلاحية للوصول إلى هذه البيانات');
}

/// Cache Exceptions
class CacheException extends AppException {
  CacheException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);

  @override
  String toString() => 'CacheException: $message';
}

/// Payment Exceptions
class PaymentException extends AppException {
  PaymentException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);

  @override
  String toString() => 'PaymentException: $message';
}

class InsufficientFundsException extends PaymentException {
  InsufficientFundsException()
      : super('الرصيد غير كافٍ');
}

class PaymentDeclinedException extends PaymentException {
  PaymentDeclinedException()
      : super('تم رفض الدفع. يرجى التواصل مع البنك.');
}

/// File/Storage Exceptions
class StorageException extends AppException {
  StorageException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);

  @override
  String toString() => 'StorageException: $message';
}

class FileUploadException extends StorageException {
  FileUploadException([String message = 'فشل رفع الملف'])
      : super(message);
}

class FileTooLargeException extends StorageException {
  FileTooLargeException()
      : super('حجم الملف كبير جداً. الحد الأقصى 10MB');
}

/// Rate Limiting Exception
class RateLimitException extends AppException {
  final DateTime? retryAfter;

  RateLimitException({
    String message = 'تم تجاوز الحد المسموح. يرجى المحاولة لاحقاً',
    this.retryAfter,
  }) : super(message);

  @override
  String toString() => 'RateLimitException: $message';
}

/// Unknown Exception
class UnknownException extends AppException {
  UnknownException([String message = 'حدث خطأ غير متوقع'])
      : super(message);

  @override
  String toString() => 'UnknownException: $message';
}
