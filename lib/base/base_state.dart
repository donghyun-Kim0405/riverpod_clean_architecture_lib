

import '../enums/page_state.dart';

abstract class BaseState<T> {
  PageState pageState;

  BaseState({this.pageState = PageState.DEFAULT});

  T copyWith({PageState? pageState});
}