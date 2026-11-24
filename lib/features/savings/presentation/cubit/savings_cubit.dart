import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:saveit/features/savings/domain/entities/savings.dart';
import 'package:saveit/features/savings/domain/repositories/savings_repository.dart';
import 'package:saveit/features/auth/domain/repositories/auth_repository.dart';

class SavingsState {
  const SavingsState({
    this.daily,
    this.weekly = const [],
    this.monthly = const {},
    this.isLoading = true,
  });

  final SavingsModel? daily;
  final List<Map<String, dynamic>> weekly;
  final Map<String, dynamic> monthly;
  final bool isLoading;
}

@injectable
class SavingsCubit extends Cubit<SavingsState> {
  SavingsCubit(this._repository, this._auth) : super(const SavingsState());

  final SavingsRepository _repository;
  final AuthRepository _auth;
  StreamSubscription<SavingsModel?>? _subscription;
  SavingsModel? _daily;
  int _request = 0;

  void start() {
    _subscription = _repository.getSavingsStream().listen((daily) {
      _daily = daily;
      unawaited(refresh());
    }, onError: (Object _) => unawaited(refresh()));
  }

  Future<void> refresh() async {
    final request = ++_request;
    final weekly = await _repository.getWeeklyExpenseData();
    final monthly = await _repository.getMonthlySavingsSummary();
    if (isClosed || request != _request) return;
    emit(
      SavingsState(
        daily: _daily,
        weekly: List.unmodifiable(weekly),
        monthly: Map.unmodifiable(monthly),
        isLoading: false,
      ),
    );
  }

  Future<bool> calculateToday() async {
    final id = _auth.session?.id;
    if (id == null) return false;
    await _repository.calculateDailySavings(id);
    await refresh();
    return true;
  }

  @override
  Future<void> close() async {
    ++_request;
    await _subscription?.cancel();
    return super.close();
  }
}
