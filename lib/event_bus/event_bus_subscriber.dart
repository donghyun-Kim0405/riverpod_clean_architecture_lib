
import 'event_bus_base_event.dart';

abstract class EventBusSubscriber<T extends EventBusBaseEvent> {

  void subscribe();
  void unSubscribe();
  void onEvent(T event);
}
