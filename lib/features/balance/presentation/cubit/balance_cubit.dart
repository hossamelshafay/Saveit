import 'package:injectable/injectable.dart';
import 'package:saveit/core/utils/watch_cubit.dart';
import 'package:saveit/features/balance/domain/repositories/balance_repository.dart';

@injectable
class BalanceCubit extends WatchCubit<Map<String, dynamic>> {
  BalanceCubit(this._repository);

  final BalanceRepository _repository;

  void start() => watch(_repository.watchFinancials());
}
