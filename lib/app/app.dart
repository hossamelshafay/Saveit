import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:saveit/features/auth/domain/repositories/auth_repository.dart';
import 'package:saveit/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:saveit/features/settings/presentation/cubit/settings_cubit.dart';

import 'router/app_router.dart';
import 'router/route_guards.dart';
import 'theme/app_theme.dart';

class SaveItApp extends StatefulWidget {
  const SaveItApp({super.key, required this.dependencies});

  final GetIt dependencies;

  @override
  State<SaveItApp> createState() => _SaveItAppState();
}

class _SaveItAppState extends State<SaveItApp> {
  late final RouteGuards _guards;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _guards = RouteGuards(widget.dependencies<AuthRepository>());
    _router = createAppRouter(widget.dependencies, _guards);
  }

  @override
  void dispose() {
    _router.dispose();
    _guards.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.dependencies<SettingsCubit>()),
        BlocProvider.value(value: widget.dependencies<ProfileCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (previous, current) => previous.isArabic != current.isArabic,
        builder: (context, state) => MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'SaveIt',
          theme: AppTheme.light,
          locale: state.isArabic
              ? const Locale('ar', 'SA')
              : const Locale('en', 'US'),
          supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          routerConfig: _router,
        ),
      ),
    );
  }
}
