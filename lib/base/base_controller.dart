
import 'dart:math';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_clean_architecture_lib/riverpod_cleanarchitecture.dart';
import '../enums/app_state.dart';
import '../enums/page_state.dart';
import '../exceptions/custom_exception/custom_exception.dart';
import '../managers/view_route_manager.dart';
import '../utils/size_util.dart';
import 'base_state.dart';


/**
 * Todo - 각 controller는 현재
 * */
abstract class BaseController<T extends BaseState> extends StateNotifier<T> with WidgetsBindingObserver{
  BaseController(super.state) {
    WidgetsBinding.instance.addObserver(this);
    onInit();
    /// onInit처럼 생성자를 통해 초기화 코드 실행
  }

  Logger logger = RiverpodCleanArchitecture.logger;

  AppState _appState = AppState.ON_RESUME;

  PageState get pageState => state.pageState;

  updatePageState({required PageState pageState}) => state = state.copyWith(pageState: pageState);

  resetPageState() => state = state.copyWith(pageState: PageState.DEFAULT);

  showLoading() => state = state.copyWith(pageState: PageState.LOADING); // 수정: 제네릭 타입 T 제거

  hideLoading() => resetPageState();

  showToastMessage({required String message}) => Fluttertoast.showToast(msg: message);

  AppLifecycleState? lastLifeCycle = null;


  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final BuildContext? context = RouteManager.instance.navigatorKey.currentState?.context;
    if (context != null && _appState == AppState.ON_RESUME) {
      SizeUtil.setSizeUsingContext(context);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    manageLifecycle(appLifecycleState: state);
    super.didChangeAppLifecycleState(state);
  }
  onInit(){
    logger.i("constructor called() - onInit()");
  }
  onResumed(){
    _appState = AppState.ON_RESUME;
    logger.i("onResume() - ${T}");
  }
  onInActive(){
    _appState = AppState.ON_IN_ACTIVE;
    logger.i("onInActive() - ${T}");
  }
  onPaused(){
    _appState = AppState.ON_PAUSED;
    logger.i("onPaused() - ${T}");
  }
  onDetached(){
    _appState = AppState.ON_DETACHED;
    logger.i("onDetached() - ${T}");
  }
  onHidden(){
    _appState = AppState.ON_HIDDEN;
    logger.i("onHidden() - ${T}");
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    logger.i("RiverpodBaseController - dispose() called");
    super.dispose();
  }

  manageLifecycle({required AppLifecycleState appLifecycleState}) {
    /// 이전과 동일한 라이프 싸이클 상태라면 그냥 리턴 -> 중복 호출되는것을 막기위함
    if (appLifecycleState == lastLifeCycle) return;

    lastLifeCycle = appLifecycleState;

    /// 마지막 lifecycle을 갱신함

    logger.i("App LifeCycle Changed - $appLifecycleState}");

    switch (appLifecycleState) {
      case AppLifecycleState.resumed:
        onResumed();
        break;
      case AppLifecycleState.inactive:
        onInActive();
        break;
      case AppLifecycleState.paused:
        onPaused();
        break;
      case AppLifecycleState.detached:
        onDetached();
        break;
    }
  }

  dynamic callDataService<T>(
      { required Future<T> Function() futureProvider,
        Function(Exception exception)? onError,
        Function(T response)? onSuccess,
        Function? onStart,
        Function? onComplete,
        bool doNotWhenLoading = false
      }) async {

    if(doNotWhenLoading && pageState == PageState.LOADING) return;

    CustomException? _exception;
    StackTrace? _stackTrace;

    onStart == null ? showLoading() : onStart();

    try {
      final T response = await futureProvider();

      if(!mounted) return;

      onComplete == null ? hideLoading() : onComplete();

      if (onSuccess != null) onSuccess(response);

      return response;
    } on CustomException catch (customException, stackTrace) {

      customException.log();
      _exception = customException; /// customException이 들어왔다는것은 이미 가공되었다는 의미로 아무동작도 수행하지 않고 그대로 할당만하고 넘어감
      _stackTrace = stackTrace;
    } catch (e, s) {
      logger.e("BaseController.CallDataService 오류 발생 마지막 Catch 까지 이동  - Error: ${e.toString()}");
      _exception = CustomException(msgForUser: "오류가 발생했습니다. 증상이 지속되면 관리자에게 문의하세요.");
      _stackTrace = s;
    }

    /// 이 지점에 도달했다는것은 위 try문안에서 return 하지 못했으므로 오류가 있다고 가정하고 CrashLytics에 보고
    await FirebaseCrashlytics.instance.recordError(_exception.msgForDev, _stackTrace ?? StackTrace.current, printDetails: true);

    if (onError != null) {
      onError(_exception);
    } else {
      showToastMessage(message: _exception.msgForUser);
    }

    onComplete == null ? hideLoading() : onComplete();
  }

}