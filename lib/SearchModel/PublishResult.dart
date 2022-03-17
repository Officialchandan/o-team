
import 'dart:async';

import 'package:rxdart/rxdart.dart';

class PublishSubject<T> extends Subject<T> {
  PublishSubject._(StreamController<T> controller, observable)
      : super(controller, observable);
  factory PublishSubject(
      {void onListen(), Future<dynamic> onCancel(), bool sync: false}) {
    final controller =  StreamController<T>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
      sync: sync,
    );
    return new PublishSubject<T>._(
      controller,
      controller.stream,
    );
  }

  @override
  Subject<R> createForwardingSubject<R>({void Function() onListen, void Function() onCancel, bool sync = false}) {
    // TODO: implement createForwardingSubject
    throw UnimplementedError();
  }
}
