
import 'package:dio/dio.dart';
import 'package:riverpod_clean_architecture_lib/riverpod_cleanarchitecture.dart';
import '../enums/request_type.dart';
import '../exceptions/custom_exception/custom_api_response_parsing_exception.dart';
import '../exceptions/custom_exception/custom_exception.dart';
import '../exceptions/hanlers/dio_exception_handler.dart';
import '../network/api_response.dart';
import '../source/db_source.dart';

abstract class BaseRepository {

  Dio dio;

  DBSource? db;

  final logger = RiverpodCleanArchitecture.logger;

  BaseRepository({required this.dio, this.db});


  Future<dynamic> callApiWithErrorParser<T>({
    required RequestType requestType,
    required String endPoint,
    required Map<String, dynamic>? reqDto,
    required T Function(Map<String, dynamic>)? fromJsonT, // 수정된 타입 선언
  }) async {
    try {
      Response response = await _performRequest(requestType, endPoint, reqDto); // 요청 실행 로직을 함수로 분리

      if(response.data['data'] == null) {
        ApiEmptyDataResponse apiResponse = ApiEmptyDataResponse.fromJson(response: response);

        if(apiResponse.status != 200 || apiResponse.message != "ok") {
          throw CustomException(
              msgForDev: "[response.data['data'] == null] callApiWithErrorParser (apiResponse.status != 200 혹은 apiResponse.message가 ok가 아닙니다.) - apiResponse.message : ${apiResponse.message}",
              msgForUser: apiResponse.message ?? '서버 오류가 발생하였습니다. 관리자에게 문의하세요.'
          );
        }

        return;
      } else if (response.data['data'] is List) {
        ApiListResponse<T> apiResponse = ApiListResponse.fromJson(
            response: response,
            fromJsonT: (json) => fromJsonT!(json as Map<String, dynamic>)
        );
        if(apiResponse.status != 200 || apiResponse.message != "ok") {
          throw CustomException(
              msgForDev: "[response.data['data'] is List]callApiWithErrorParser (apiResponse.status != 200 혹은 apiResponse.message가 ok가 아닙니다.) - apiResponse.message : ${apiResponse.message}",
              msgForUser: apiResponse.message ?? '서버 오류가 발생하였습니다. 관리자에게 문의하세요.'
          );
        }

        if(apiResponse.data == null) {
          throw CustomException(
              msgForDev: 'callApiWithErrorParser() 실행 중 오류 - 응답 결과가 없습니다. \n apiResponse.data == null 상황 발생',
              msgForUser: '응답 결과가 없습니다.'
          );
        }

        return apiResponse.data!;
      } else if (response.data['data'] is Map) {
        ApiResponse<T> apiResponse = ApiResponse.fromJson(
            response: response,
            fromJsonT: (json) => fromJsonT!(json as Map<String, dynamic>)
        );

        if(apiResponse.status != 200 || apiResponse.message != "ok") {
          throw CustomException(
              msgForDev: "[response.data['data'] is Map] callApiWithErrorParser (apiResponse.status != 200 혹은 apiResponse.message가 ok가 아닙니다.) - apiResponse.message : ${apiResponse.message}",
              msgForUser: apiResponse.message ?? '서버 오류가 발생하였습니다. 관리자에게 문의하세요.'
          );
        }

        if(apiResponse.data == null) {
          throw CustomException(
              msgForDev: 'callApiWithErrorParser() 실행 중 오류 - 응답 결과가 없습니다. \n apiResponse.data == null 상황 발생',
              msgForUser: '응답 결과가 없습니다.'
          );
        }

        return apiResponse.data!;
      } else {
        throw Exception("Unsupported data type");
      }
    }  on CustomApiResponseParsingException catch(exception) {
      exception.log();
      rethrow;  /// 이미 ApiResponse내부에서 예외처리 수행되었음

    } on DioException catch(dioException) {
      logger.i(dioException.message);
      throw DioExceptionHandler.handleDioError(dioException);

    } catch (e, s) {
      logger.e("BaseRepository Catch Error: ${e.toString()}");
      logger.e("BaseRepository StackTrace: ${s.toString()}");
      rethrow;
    }
  }

  Future<Response> _performRequest(RequestType requestType, String endPoint, Map<String, dynamic>? reqDto) async {
    switch (requestType) {
      case RequestType.GET:
        return await dio.get(endPoint, queryParameters: reqDto);
      case RequestType.POST:
        return await dio.post(endPoint, data: reqDto);
      case RequestType.PUT:
        return await dio.put(endPoint, data: reqDto);
      case RequestType.DELETE:
        return await dio.delete(endPoint, queryParameters: reqDto);
      default:
        throw Exception("Invalid request type");
    }
  }




}


