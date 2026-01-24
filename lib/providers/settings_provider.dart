import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdoneapp/models/common/settings.dart';
import 'package:bdoneapp/providers/providers.dart';

final settingsFutureProvider = FutureProvider<SettingsResponse>((ref) async {
  return ref.read(settingsServiceProvider).fetch();
});

final settingsProvider = Provider<SettingsData?>((ref) {
  final asyncSettings = ref.watch(settingsFutureProvider);
  return asyncSettings.maybeWhen(
    data: (value) => value.data,
    orElse: () => null,
  );
});
