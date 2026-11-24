import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saveit/core/errors/error_handler.dart';

typedef WatchState<T> = ({T? data, String? error});

abstract class WatchCubit<T> extends Cubit<WatchState<T>> {
  WatchCubit() : super((data: null, error: null));

  StreamSubscription<T>? _subscription;

  void watch(Stream<T> stream) {
    if (_subscription != null) return;
    _subscription = stream.listen(
      (data) => emit((data: data, error: null)),
      onError: (Object error) =>
          emit((data: null, error: ErrorHandler.from(error).message)),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
