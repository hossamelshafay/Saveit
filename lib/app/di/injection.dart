import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

@InjectableInit(preferRelativeImports: true)
GetIt configureDependencies(GetIt container) => container.init();
