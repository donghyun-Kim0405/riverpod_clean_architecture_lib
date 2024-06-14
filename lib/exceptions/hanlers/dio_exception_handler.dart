import 'package:dio/dio.dart';
import '../custom_exception/custom_exception.dart';

abstract class DioExceptionHandler {
  static CustomException handleDioError(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.cancel:
        return CustomException(
            msgForUser: "네트워크 연결상태를 확인하세요",
            msgForDev: dioException.message ?? "",
            stackTrace: dioException.stackTrace);
      case DioExceptionType.connectionTimeout:
        return CustomException(
            msgForUser: "네트워크 연결상태를 확인하세요",
            msgForDev: dioException.message ?? "",
            stackTrace: dioException.stackTrace);
      case DioExceptionType.unknown:

        return CustomException(
            msgForUser: "(unknown) 네트워크 오류가 발생했습니다. 관리자에게 문의하세요 ",
            msgForDev: dioException.message ?? "",
            stackTrace: dioException.stackTrace);
      case DioExceptionType.receiveTimeout:
        return CustomException(
            msgForUser: "네트워크 연결상태를 확인하세요",
            msgForDev: dioException.message ?? "",
            stackTrace: dioException.stackTrace);
      case DioExceptionType.sendTimeout:
        return CustomException(
            msgForUser: "네트워크 연결상태를 확인하세요",
            msgForDev: dioException.message ?? "",
            stackTrace: dioException.stackTrace);
      case DioExceptionType.badResponse:
        String message = '잘못된 요청입니다. 관리자에게 문의하세요';

        if (dioException.response?.statusCode == 429) {
          message = '비 정상 적인 요청이 감지되었습니다. 잠시 후 다시 시도해주세요.';
        } else if (dioException.response?.data['message'] != null) {
          message = dioException.response!.data['message'];
        } else if (dioException.message != null) {
          message = dioException.message!;
        } else if (dioException.response?.statusMessage != null) {
          message = dioException.response!.statusMessage!;
        }
        return CustomException(
            msgForUser: message,
            msgForDev: dioException.message ?? "",
            stackTrace: dioException.stackTrace);
      default:
        return CustomException(
            msgForUser: dioException.response?.statusMessage ??
                'Bad Request 관리자에게 문의하세요',
            msgForDev: dioException.message ?? "",
            stackTrace: dioException.stackTrace);
    }
  }
}
