import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdcomputing/core/app_wrapper.dart';
import 'package:bdcomputing/core/routes.dart';
import 'package:bdcomputing/core/theme/app_theme.dart';
import 'package:bdcomputing/components/widgets/currency_initializer.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('onboarding_complete') ?? false;

  runApp(
    ProviderScope(child: BdcomputingPartner(showOnboarding: !seenOnboarding)),
  );
}

class BdcomputingPartner extends StatelessWidget {
  final bool showOnboarding;
  const BdcomputingPartner({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BD OTG',

      // Light theme
      theme: AppTheme.lightTheme,

      // Dark theme
      darkTheme: AppTheme.darkTheme,

      // Respect system theme preference
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRoutes.generateRoute,
      initialRoute: showOnboarding ? AppRoutes.onboarding : AppRoutes.home,
      builder: (context, child) {
        return AppWrapper(
          child: CurrencyInitializer(child: child ?? const SizedBox()),
        );
      },
    );
  }
}
