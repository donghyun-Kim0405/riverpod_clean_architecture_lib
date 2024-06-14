
import 'package:riverpod_clean_architecture_lib/riverpod_cleanarchitecture.dart';

import 'event_bus_base_event.dart';
import 'event_bus_subscriber.dart';



/**
 * 만약 publishing과 unSubscribe가 동시에 발생할 경우 오류가 발생한다.
 *
 * 이유 -> for문으로 iterable객체에 순회를 하는중간에 특정 요소를 제거할 수 없다.
 * 즉 publishing에서 순회를 하고있는데 동시에 unSubscribe가발생한다면
 * 동일객체에 순회와 수정이 동시에 발생하여 오류를 일으킨다.
 * 이것을 대응하기 위해 publish에서는 메서드는 초입부에 copy본을 생성하여
 * 그것을 이용하여 순회하고 event를 발행하도록 한다.
 * */
class EventBus {
  EventBus._();

  static final EventBus _instance = EventBus._();

  static EventBus get instance => _instance;

  final logger = RiverpodCleanArchitecture.logger;

  // 각 이벤트 타입에 대한 구독자 목록을 관리합니다.
  final Map<Type, List<EventBusSubscriber<EventBusBaseEvent>>> _subscribers = {};

  /// 구독
  void subscribe<T extends EventBusBaseEvent>({required EventBusSubscriber<T> subscriber}) {
    _subscribers.putIfAbsent(T, () => []);

    _subscribers[T]?.removeWhere((element) => element.runtimeType == subscriber.runtimeType);

    _subscribers[T]!.add(subscriber);

    RiverpodCleanArchitecture.logger.i("subscriber - ${subscriber.runtimeType}");
  }


  /// 구독 해제
  void unSubscribe<T extends EventBusBaseEvent>({required EventBusSubscriber<T> subscriber}) {
    _subscribers[T]?.removeWhere((element) => element.runtimeType == subscriber.runtimeType);
    _subscribers[T]?.remove(subscriber);
  }

  /// 퍼블리싱
  void publish<T extends EventBusBaseEvent>({required T event}) {
    logger.i("EventBus.publish() : ${event}");
    logger.i("subscriber : ${_subscribers}");
    List<EventBusSubscriber<EventBusBaseEvent>>? subscribersOfType = _subscribers[T];
    if (subscribersOfType != null) {
      // 구독자 목록의 복사본을 만들어 반복
      List<EventBusSubscriber<EventBusBaseEvent>> subscribersSnapshot = List.from(subscribersOfType);
      for (var subscriber in subscribersSnapshot) {
        subscriber.onEvent(event);
      }
    }
  }
}