import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:get_storage/get_storage.dart';

typedef SettingsState = ({bool isArabic, bool notificationsEnabled});

@lazySingleton
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
    : super((
        isArabic: GetStorage().read<bool>('isArabic') ?? false,
        notificationsEnabled: GetStorage().read<bool>('notifications') ?? true,
      ));

  void setLanguage({required bool isArabic}) => emit((
    isArabic: isArabic,
    notificationsEnabled: state.notificationsEnabled,
  ));

  void setNotifications(bool enabled) =>
      emit((isArabic: state.isArabic, notificationsEnabled: enabled));
}
