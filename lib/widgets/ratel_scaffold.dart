import 'package:flutter/material.dart';

/// One standard screen scaffold for Ratel: a themed app-bar header
/// (title + back/close), a safe-area body with optional standard page
/// padding, and an optional persistent bottom action bar.
///
/// Replaces ad-hoc `Scaffold`/`AppBar` so every screen shares the same
/// header, padding and safe-area behaviour. The header inherits the app's
/// `AppBarTheme`, so adopting this on an existing screen is a no-visual-change
/// refactor today; the final look of the header is owner-taste and can evolve
/// here in one place (Standardization Master Plan, Pillar A).
class RatelScaffold extends StatelessWidget {
  const RatelScaffold({
    super.key,
    this.title,
    this.titleWidget,
    required this.body,
    this.actions,
    this.leading,
    this.onClose,
    this.bottomBar,
    this.padding,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
  });

  /// Header title text. Ignored when [titleWidget] is provided.
  final String? title;

  /// Custom header title widget (overrides [title]).
  final Widget? titleWidget;

  /// Screen content. If [padding] is null the body is responsible for its
  /// own padding (so already-padded scroll views are not double-inset).
  final Widget body;

  /// Trailing header actions.
  final List<Widget>? actions;

  /// Custom leading widget. When null, the framework supplies the standard
  /// back button for pushed routes (unless [onClose] is set, which shows a
  /// close button instead).
  final Widget? leading;

  /// When set, the header shows a close (X) button — labelled "Close" for
  /// screen readers — that calls this, instead of the default back arrow.
  final VoidCallback? onClose;

  /// Optional persistent bottom action bar (e.g. a primary CTA). It is
  /// safe-area padded and given standard horizontal insets.
  final Widget? bottomBar;

  /// Optional padding around [body]. Null = none (the body pads itself).
  /// Use [pagePadding] for the standard inset.
  final EdgeInsetsGeometry? padding;

  /// Scaffold background; null uses the theme's scaffold background.
  final Color? backgroundColor;

  /// Forwarded to [AppBar.automaticallyImplyLeading].
  final bool automaticallyImplyLeading;

  /// The standard page padding screens may opt into.
  static const EdgeInsets pagePadding = EdgeInsets.all(16);

  @override
  Widget build(BuildContext context) {
    Widget content = body;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }
    // The app bar already insets the top; guard the sides and bottom for
    // notches / home indicators without re-insetting the top.
    content = SafeArea(top: false, child: content);

    Widget? lead = leading;
    if (lead == null && onClose != null) {
      lead = IconButton(
        icon: const Icon(Icons.close),
        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
        onPressed: onClose,
      );
    }

    Widget? bottom;
    if (bottomBar != null) {
      bottom = SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: bottomBar,
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: lead,
        automaticallyImplyLeading: automaticallyImplyLeading,
        title: titleWidget ?? (title != null ? Text(title!) : null),
        actions: actions,
      ),
      body: content,
      bottomNavigationBar: bottom,
    );
  }
}
