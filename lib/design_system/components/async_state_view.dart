import 'package:flutter/material.dart';
import '../../core/i18n/strings.dart';
import 'ratel_empty_state.dart';
import 'ratel_error_retry.dart';
import 'ratel_skeleton.dart';

/// UI-only load-state enum. The controller/data-layer mapping is Phase 3.
enum RatelLoadState { loading, data, empty, error }

/// The documented loading / empty / error / data convention. A screen holds a
/// [RatelLoadState] (today hard-set to `.data`, since stubs are always present)
/// and wraps its body in this switch; Phase 3 flips the field from a controller.
class AsyncStateView extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.state,
    required this.data,
    this.loading,
    this.empty,
    this.error,
    this.onRetry,
  });

  final RatelLoadState state;
  final WidgetBuilder data;
  final Widget? loading;
  final Widget? empty;
  final Widget? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      RatelLoadState.loading => loading ?? const RatelSkeletonList(),
      RatelLoadState.data => data(context),
      RatelLoadState.empty => empty ??
          RatelEmptyState(
            icon: Icons.inbox_outlined,
            title: S.t('empty_default_title', 'Nothing here yet'),
          ),
      RatelLoadState.error => error ?? RatelErrorRetry(onRetry: onRetry),
    };
  }
}
