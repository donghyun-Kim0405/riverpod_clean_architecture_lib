
import 'package:dio/dio.dart';
import 'package:riverpod_clean_architecture_lib/riverpod_cleanarchitecture.dart';

import '../exceptions/custom_exception/custom_api_response_parsing_exception.dart';


class ApiEmptyDataResponse {
  num? status;  /// 서버로 부터 받은 메시지
  String? message; /// 서버로부터 받은메시지 혹은 내부에서 발생한 오류 메시지
  ApiEmptyDataResponse({this.status, this.message});

  factory ApiEmptyDataResponse.fromJson({required Response response}) {
    num? status;
    String? message;

    try {
      status = response.data['status'];
      message = response.data['message'];
    } catch (e, s) {
      throw CustomApiResponseParsingException(msgForUser: "네트워크 응답 결과를 읽어오지 못했습니다. 관리자에게 문의하세요.", msgForDev: "ApiParsingError - ${e.toString()}", stackTrace: s);
    }

    return ApiEmptyDataResponse(
      status: status,
      message: message,
    );
  }
}

class ApiResponse<T> {
  T? data;  /// 서버로 부터 응답받을 데이터
  num? status;  /// 서버로 부터 받은 메시지
  String? message; /// 서버로부터 받은메시지 혹은 내부에서 발생한 오류 메시지

  ApiResponse({this.data, this.status, this.message});

  factory ApiResponse.fromJson({
    required Response response,
    required T Function(Object? json) fromJsonT,
    }) {

    Map<String, dynamic> json = response.data;

    T? data;
    num? status;
    String? message;

    try {
      data = fromJsonT(json['data']);
      status = response.data['status'];
      message = response.data['message'];
      RiverpodCleanArchitecture.logger.i(data);
    } catch (e, s) {
      throw CustomApiResponseParsingException(msgForUser: "네트워크 응답 결과를 읽어오지 못했습니다. 관리자에게 문의하세요.", msgForDev: "ApiParsingError - ${e.toString()}", stackTrace: s);
    }

    return ApiResponse(
      data: data,
      status: status,
      message: message,
    );
  }
}

class ApiListResponse<T> {
  List<T>? data;  /// 서버로 부터 응답받을 데이터
  num? status;  /// 서버로 부터 받은 메시지
  String? message; /// 서버로부터 받은메시지 혹은 내부에서 발생한 오류 메시지

  ApiListResponse({this.data, this.status, this.message});

  factory ApiListResponse.fromJson({
    required Response response,
    required T Function(Object? json) fromJsonT,
  }) {

    Map<String, dynamic> json = response.data;

    List<T>? data;
    num? status;
    String? message;

    try {
      if (json['data'] is List) {
        List<dynamic> jsonDataList = json['data'];
        data = jsonDataList.map((itemJson) => fromJsonT(itemJson)).toList() as List<T>;
      }
      status = response.data['status'];
      message = response.data['message'];
    } catch (e, s) {
      throw CustomApiResponseParsingException(msgForUser: "네트워크 응답 결과를 읽어오지 못했습니다. 관리자에게 문의하세요.", msgForDev: "ApiParsingError - ${e.toString()}", stackTrace: s);
    }

    return ApiListResponse(
      data: data,
      status: status,
      message: message,
    );
  }
}

