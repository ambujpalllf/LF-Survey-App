// import 'package:dio/dio.dart';

// class ApiException implements Exception {
//   final String message;
//   final int? statusCode;

//   ApiException({required this.message, this.statusCode});

//   factory ApiException.fromDioError(DioException error) {
//     switch (error.type) {
//       case DioExceptionType.connectionTimeout:
//         return ApiException(message: "Connection timeout");
//       case DioExceptionType.sendTimeout:
//         return ApiException(message: "Send timeout");
//       case DioExceptionType.receiveTimeout:
//         return ApiException(message: "Receive timeout");
//       case DioExceptionType.badResponse:
//         return ApiException(
//           message: error.response?.data['message'] ?? "Bad response",
//           statusCode: error.response?.statusCode,
//         );
//       case DioExceptionType.cancel:
//         return ApiException(message: "Request cancelled");
//       case DioExceptionType.unknown:
//       default:
//         return ApiException(message: "Unexpected error occurred");
//     }
//   }

//   @override
//   String toString() => "ApiException: $message (code: $statusCode)";

// }

import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(message: "Connection timeout. Please try again.");
      case DioExceptionType.sendTimeout:
        return ApiException(message: "Send timeout. Check your connection.");
      case DioExceptionType.receiveTimeout:
        return ApiException(message: "Receive timeout. Try again later.");
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode ?? 0;
        final msg = _handleStatusCode(status, error.response?.data);
        return ApiException(message: msg, statusCode: status);
      case DioExceptionType.cancel:
        return ApiException(message: "Request was cancelled.", statusCode: error.response?.statusCode ?? 0);
      case DioExceptionType.connectionError:
        return ApiException(message: "No internet connection. Please check.");
      default:
        return ApiException(message: "Something went wrong. Please try again.");
    }
  }

  static String _handleStatusCode(int status, dynamic data) {
    switch (status) {
      case 400:
        return data?['message'] ?? "Bad Request.";
      case 401:
        return "Unauthorized. Please login again.";
      case 403:
        return "Forbidden. You don't have access.";
      case 404:
        return "Not Found. Check the URL.";
      case 500:
        return "Server error. Please try later.";
      default:
        return "Unexpected error occurred ($status).";
    }
  }

  @override
  String toString() => message;
}
