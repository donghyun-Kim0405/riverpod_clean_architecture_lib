import 'package:dio/dio.dart';
import '../../managers/preference_manager.dart';
import '../../managers/view_route_manager.dart';
import '../enums/network_tags.dart';
import 'api_response.dart';
import 'tokens_model.dart';
import '../riverpod_cleanarchitecture.dart';

class JwtInterceptor extends Interceptor {
  final Dio _dio;

  JwtInterceptor(this._dio);

  Future<bool> refreshToken() async {

    try {
      String? refreshToken = await PrefManager.instance.getString(NetworkTags.REFRESH_TOKEN);

      if(refreshToken == null) return false;

      Dio dioWithoutInterceptor = await Dio();

      dioWithoutInterceptor.options.headers['Authorization'] = 'Bearer ${refreshToken}';

      Response response = await dioWithoutInterceptor.get('${RiverpodCleanArchitecture.baseUrl}${RiverpodCleanArchitecture.refreshTokenEndPoint}');

      if(response.statusCode == 200) {

        ApiResponse<TokensModel> apiResponse = ApiResponse.fromJson(
                response: response,
                fromJsonT: (json) => TokensModel.fromJson(json as Map<String, dynamic>)
              );

        if(
            apiResponse.data != null &&
            apiResponse.status == 200 &&
            apiResponse.message == "ok"
        ) {

          PrefManager prefManager = PrefManager.instance;

          await prefManager.setString(NetworkTags.ACCESS_TOKEN, apiResponse.data!.accessToken ?? '');
          await prefManager.setString(NetworkTags.REFRESH_TOKEN, apiResponse.data!.refreshToken ?? '');

          return true;
        }
      }
    } catch (e, s) {
      RiverpodCleanArchitecture.logger.e('Failed to refresh token: ' + s.toString());
      RiverpodCleanArchitecture.logger.e('Failed to refresh token: $e');
      rethrow;
    }
    return false;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    String? accessToken = await PrefManager.instance.getString(NetworkTags.ACCESS_TOKEN);
    options.headers['Authorization'] = 'Bearer ${accessToken}';
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        bool flag = await refreshToken(); // 토큰 갱신 시도
        if (!flag) {
          // 토큰 갱신 실패 시 로그인 화면으로 이동
          await PrefManager.instance.setString(NetworkTags.ACCESS_TOKEN, "");
          await PrefManager.instance.setString(NetworkTags.REFRESH_TOKEN, "");
          RouteManager.instance.pushNamed(
          	context: null,
          	routes: RiverpodCleanArchitecture.routeForLoggedOut
          );
          return;
        }

        // 토큰 갱신 성공 시, 새로운 토큰으로 요청 재시도
        String? newAccessToken = await PrefManager.instance.getString(NetworkTags.ACCESS_TOKEN);

        final RequestOptions options = err.requestOptions;

        options.headers['Authorization'] = 'Bearer $newAccessToken';

        return Dio().fetch(options).then(
              (response) => handler.resolve(response),
          onError: (e) => handler.next(e),
        );
      } catch (e) {
        handler.next(err); // 갱신 실패 시, 원래의 에러를 처리
      }
    } else {
      super.onError(err, handler); // 다른 모든 오류는 기본 처리
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response?.statusCode == 401) {
      try {
        bool flag = await refreshToken();
        if(!flag) {   //토큰 갱신에 실패한 경우
          await PrefManager.instance.setString(NetworkTags.ACCESS_TOKEN, "");
          await PrefManager.instance.setString(NetworkTags.REFRESH_TOKEN, "");

          RouteManager.instance.navigatorKey.currentState?.pushNamed(RiverpodCleanArchitecture.routeForLoggedOut);

          return;
        }


        String? newAccessToken = await PrefManager.instance.getString(NetworkTags.ACCESS_TOKEN);

        final newOptions = Options(
          method: response.requestOptions.method,
          headers: {
            ...response.requestOptions.headers,
            "Authorization": "Bearer $newAccessToken", // 새로운 AccessToken으로 헤더 업데이트
          },
          responseType: response.requestOptions.responseType,
        );

        // Retry the failed request with the new access token.
        final newResponse = await _dio.request(
          response.requestOptions.path,
          cancelToken: response.requestOptions.cancelToken,
          data: response.requestOptions.data,
          onReceiveProgress: response.requestOptions.onReceiveProgress,
          onSendProgress: response.requestOptions.onSendProgress,
          queryParameters: response.requestOptions.queryParameters,
          options: newOptions, // 수정된 옵션으로 요청 보내기
        );

        handler.resolve(newResponse); // Return the new response
      } catch (e) {

        // Refreshing the token failed, handle the error.
        handler.next(response); // Passing the original response further.
      }
    } else {
      super.onResponse(response, handler); // Handling other cases
    }
  }//onResponse
}
