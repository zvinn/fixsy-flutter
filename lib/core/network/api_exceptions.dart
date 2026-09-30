import 'package:dio/dio.dart';
import '../error/exceptions.dart';

/// Structured API Exception mapped from DioException
/// Complies with Fixsy Constitution Principle II & api-standards.
class ApiException extends AppException {
  final int? statusCode;

  ApiException(
    super.message, {
    this.statusCode,
    super.code,
    super.originalError,
  });

  factory ApiException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiTimeoutException(
          'انتهت مهلة الاتصال بالخادم. يرجى المحاولة مرة أخرى.',
          originalError: error,
        );

      case DioExceptionType.connectionError:
        return ApiNetworkException(
          'تعذر الاتصال بالخادم، يرجى التحقق من اتصال الإنترنت.',
          originalError: error,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        var message = 'حدث خطأ في الخادم ($statusCode)';

        if (responseData is Map<String, dynamic> && responseData.containsKey('message')) {
          message = responseData['message'].toString();
        }

        switch (statusCode) {
          case 400:
            return ApiBadRequestException(message, statusCode: statusCode, originalError: error);
          case 401:
            return ApiUnauthorizedException('انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً.', statusCode: statusCode, originalError: error);
          case 403:
            return ApiForbiddenException('ليس لديك الصلاحية للقيام بهذا الإجراء.', statusCode: statusCode, originalError: error);
          case 404:
            return ApiNotFoundException('العنصر المطلوب غير موجود.', statusCode: statusCode, originalError: error);
          case 500:
          case 502:
          case 503:
            return ApiServerException('حدث خطأ داخلي في الخادم. يرجى المحاولة لاحقاً.', statusCode: statusCode, originalError: error);
          default:
            return ApiException(message, statusCode: statusCode, originalError: error);
        }

      case DioExceptionType.cancel:
        return ApiException('تم إلغاء الطلب.', originalError: error);

      case DioExceptionType.badCertificate:
        return ApiException('خطأ في شهادة الأمان للاتصال.', originalError: error);

      case DioExceptionType.unknown:
        return ApiException(
          'حدث خطأ غير متوقع في الاتصال.',
          originalError: error,
        );
    }
  }

  @override
  String toString() => 'ApiException(status: $statusCode, message: $message)';
}

class ApiNetworkException extends ApiException {
  ApiNetworkException(super.message, {super.statusCode, super.originalError});
}

class ApiTimeoutException extends ApiException {
  ApiTimeoutException(super.message, {super.statusCode, super.originalError});
}

class ApiUnauthorizedException extends ApiException {
  ApiUnauthorizedException(super.message, {super.statusCode, super.originalError});
}

class ApiForbiddenException extends ApiException {
  ApiForbiddenException(super.message, {super.statusCode, super.originalError});
}

class ApiNotFoundException extends ApiException {
  ApiNotFoundException(super.message, {super.statusCode, super.originalError});
}

class ApiBadRequestException extends ApiException {
  ApiBadRequestException(super.message, {super.statusCode, super.originalError});
}

class ApiServerException extends ApiException {
  ApiServerException(super.message, {super.statusCode, super.originalError});
}
