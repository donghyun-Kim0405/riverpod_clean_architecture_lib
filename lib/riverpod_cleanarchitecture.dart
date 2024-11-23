
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_clean_architecture_lib/utils/size_util.dart';

import 'managers/view_route_manager.dart';

class RiverpodCleanArchitecture {
  RiverpodCleanArchitecture._();

  static late RiverpodCleanArchitectureUI _ui;
  static RiverpodCleanArchitectureUI get ui => _ui;

  static late Logger _logger;
  static Logger get logger => _logger;

  static late List<String> _createQueryList;
  static List<String> get createQueryList => _createQueryList;

  static late String _baseUrl;
  static String get baseUrl => _baseUrl;

  static late String _refreshTokenEndPoint;
  static String get refreshTokenEndPoint => _refreshTokenEndPoint;

  static late String _accessTokenEndPoint;
  static String get accessTokenEndPoint => _accessTokenEndPoint;

  static late String _routeForLoggedOut;
  static String get routeForLoggedOut => _routeForLoggedOut;

  static materialApp({
    required RiverpodCleanArchitectureUI ui,
    required Logger logger,
    required List<String> createQueryList,
    required String baseUrl,
    required String refreshTokenEndPoint,
    required String accessTokenEndPoint,
    required String routeForLoggedOut,
    required String initialRoute,
    required Map<String, WidgetBuilder> routes,
    required Function sizeUtilInitiatedCallback

  }) {

    _ui = ui;
    _logger = logger;
    _createQueryList = createQueryList;
    _baseUrl = baseUrl;
    _refreshTokenEndPoint = refreshTokenEndPoint;
    _accessTokenEndPoint = accessTokenEndPoint;
    _routeForLoggedOut = routeForLoggedOut;

    return ProviderScope(
      child: MaterialApp(
        builder: (context, child) {
          SizeUtil.setSizeUsingContext(context);
          sizeUtilInitiatedCallback();
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('ko', 'KR'),
        ],
        themeMode: ThemeMode.light,
        theme: ThemeData(primarySwatch: Colors.blue, fontFamily: _ui.fontFamily),
        routes: routes,
        initialRoute: initialRoute,
        navigatorObservers: [RouteManager.instance],
        navigatorKey: RouteManager.instance.navigatorKey,
      ),
    );
  }

}


class RiverpodCleanArchitectureUI {
  late Color _mainBackgroundColor;
  Color get mainBackgroundColor => _mainBackgroundColor;

  late Color _baseBottomSheetBackgroundColor;
  Color get baseBottomSheetBackgroundColor => _baseBottomSheetBackgroundColor;

  late Color _primaryColor = Colors.blue;
  Color get primaryColor => _primaryColor;



  Color elevatedContainerColorOpacity = Colors.grey.withOpacity(0.5);

  late String _fontFamily;
  String get fontFamily => _fontFamily;

  // Public constructor
  RiverpodCleanArchitectureUI({
    required Color mainBackgroundColor,
    required String fontFamily,
    required Color baseBottomSheetBackgroundColor,
    required Color primaryColor
  }) {
    _mainBackgroundColor = mainBackgroundColor;
    _fontFamily = fontFamily;
    _baseBottomSheetBackgroundColor = baseBottomSheetBackgroundColor;
    _primaryColor = primaryColor;
  }
}
