import 'package:flutter/cupertino.dart';

/**
 * height -> 812 | width -> 375
 * 위 선언된 내용은 개발자가 디자이너로부터 전달받은 시안내 화면 사이즈 입니다.
 * 즉 디바이스 사이즈 812*375 가 기준이 되며 해당 값들을 전달받은 시간에 따라 아래와 같이 하드코딩해두고
 * 본 유틸클래스의 메서드를 호출하면서 디자인 시안의 width, 혹은 height를 그대로 입력하면
 * 각각의 디바이스 사이즈에 자동으로 맞춰주게 됩니다.
 *
 * To do
 * - Splash 혹은 Intro page에서 setSize를 수행해야 합니다.
 * */
abstract class SizeUtil{
  static Size deviceSize = Size(0, 0);
  static double statusBarH = 0.0;

  static void setSizeUsingContext(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    statusBarH = MediaQuery.of(context).padding.top;
  }

  /**
   * 앱 진입 초기 시점에 디바이스 사이즈를 비동기 식으로 읽어 set합니다.
   * 시점불일치로 set되지 않은 시점에 view를 draw하려고 시도할 경우 오류가 발생할 수 있습니다.
   * */
  static void setSize(double height, double width, double statusBarHeight){
    deviceSize = Size(width = width, height = height);
    statusBarH = statusBarHeight;
  }

  /// 높이 값 얻기
  static double height(int height){
    return deviceSize.height * (height/812);
  }

  /// 넓이 값 얻기
  static double width(int width){
    return deviceSize.width * (width/375);
  }

}

extension TopSizeUtilExtension on int {
  double get w => SizeUtil.width(this);
  double get h => SizeUtil.height(this);
}

