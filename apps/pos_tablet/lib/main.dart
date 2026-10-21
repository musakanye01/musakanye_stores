import 'package:flutter/material.dart';
import 'package:pos_tablet/di/app_dependencies.dart';
import 'package:pos_tablet/theme/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError(
      'Missing Supabase configuration. '
      'Provide SUPABASE_URL and SUPABASE_ANON_KEY.',
    );
  }

  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);

  final deps = await AppDependencies.initialize();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: PosTabletApp(dependencies: deps),
    ),
  );
}
