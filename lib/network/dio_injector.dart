


import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_clean_architecture_lib/riverpod_cleanarchitecture.dart';

import '../network/auth_interceptor.dart';


abstract class DioInjector {
  static Dio createDioWithoutToken() {
    Duration duration10Sec = const Duration(seconds: 10);
    Dio dio = Dio()
      ..options.headers["Content-Type"] = 'application/json'
      ..options.sendTimeout = duration10Sec // 10초 - 요청을 보내는데 걸린 시간
      ..options.connectTimeout = duration10Sec // 10초 - 클라이언트가 서버와 연결을 시도하고 완료하는데 걸리는 최대 시간
      ..options.receiveTimeout = duration10Sec // 10초 - 서버로부터 응답받는 데 걸리는 최대 시간
      ..options.baseUrl = RiverpodCleanArchitecture.baseUrl;

    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));

    return dio;
  }

  static Dio createDioWithToken() {
    Duration duration10Sec = const Duration(seconds: 10);
    /// defaultDio생성
    Dio dio = Dio()
      ..options.headers["Content-Type"] = 'application/json'
      ..options.sendTimeout = duration10Sec // 10초 - 요청을 보내는데 걸린 시간
      ..options.connectTimeout = duration10Sec // 10초 - 클라이언트가 서버와 연결을 시도하고 완료하는데 걸리는 최대 시간
      ..options.receiveTimeout = duration10Sec // 10초 - 서버로부터 응답받는 데 걸리는 최대 시간
      ..options.baseUrl = RiverpodCleanArchitecture.baseUrl;

    /// 이전까지 만든 defaultDio를 가지고 JwtInterceptor생성
    dio.interceptors.add(JwtInterceptor(dio));

    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));


    return dio;
  }
}