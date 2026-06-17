import 'package:flutter/widgets.dart';
import 'app_settings.dart';

/// Exposes [AppSettings] to the tree; descendants that call
/// [AppSettingsScope.of] rebuild when settings change.
class AppSettingsScope extends InheritedNotifier<AppSettings> {
  const AppSettingsScope({
    super.key,
    required AppSettings settings,
    required super.child,
  }) : super(notifier: settings);

  /// Subscribe: the caller rebuilds when settings change.
  static AppSettings of(BuildContext context) {
    final AppSettingsScope? scope =
        context.dependOnInheritedWidgetOfExactType<AppSettingsScope>();
    assert(scope?.notifier != null, 'AppSettingsScope missing above this widget');
    return scope!.notifier!;
  }

  /// Read without subscribing (for one-shot setter calls).
  static AppSettings read(BuildContext context) {
    final AppSettingsScope? scope = context
        .getElementForInheritedWidgetOfExactType<AppSettingsScope>()
        ?.widget as AppSettingsScope?;
    assert(scope?.notifier != null, 'AppSettingsScope missing above this widget');
    return scope!.notifier!;
  }
}
