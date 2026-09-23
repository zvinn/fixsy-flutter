/// Custom Exception Classes for Fixsy Flutter
/// Provides specific exception types for better error handling
library;

/// Base App Exception
class AppException implements Exception {

  AppException(this.message, {this.code, this.originalError});
  final String message;
  final String? code;
  final dynamic originalError;

  @override
  String toString() => 'AppException: $message';
}

/// Network Related Exceptions
class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.originalError});

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
  ServerException([super.message = 'خطأ في الخادم. يرجى المحاولة لاحقاً']);
}

/// Authentication Exceptions
class AuthException extends AppException {
  AuthException(super.message, {super.code, super.originalError});

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

  ValidationException(super.message, {this.fieldErrors, super.code});
  final Map<String, String>? fieldErrors;

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

  EmptyFieldException(this.fieldName)
      : super('$fieldName مطلوب');
  final String fieldName;
}

/// Firestore Exceptions
class FirestoreException extends AppException {
  FirestoreException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'FirestoreException: $message';
}

class DocumentNotFoundException extends FirestoreException {
  DocumentNotFoundException([super.message = 'البيانات غير موجودة']);
}

class PermissionDeniedException extends FirestoreException {
  PermissionDeniedException()
      : super('ليس لديك صلاحية للوصول إلى هذه البيانات');
}

/// Cache Exceptions
class CacheException extends AppException {
  CacheException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'CacheException: $message';
}

/// Payment Exceptions
class PaymentException extends AppException {
  PaymentException(super.message, {super.code, super.originalError});

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
  StorageException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'StorageException: $message';
}

class FileUploadException extends StorageException {
  FileUploadException([super.message = 'فشل رفع الملف']);
}

class FileTooLargeException extends StorageException {
  FileTooLargeException()
      : super('حجم الملف كبير جداً. الحد الأقصى 10MB');
}

/// Rate Limiting Exception
class RateLimitException extends AppException {

  RateLimitException({
    String message = 'تم تجاوز الحد المسموح. يرجى المحاولة لاحقاً',
    this.retryAfter,
  }) : super(message);
  final DateTime? retryAfter;

  @override
  String toString() => 'RateLimitException: $message';
}

/// Unknown Exception
class UnknownException extends AppException {
  UnknownException([super.message = 'حدث خطأ غير متوقع']);

  @override
  String toString() => 'UnknownException: $message';
}
