import 'package:flutter/material.dart';
import '../theme.dart';

/// Standard bottom-sheet chrome (grab handle, optional title, rounded top,
/// safe-area padding). `RatelSheet.show(context, title:..., child:...)`
/// supersedes bare showModalBottomSheet (hearts_sheet, save_account_sheet).
class RatelSheet extends StatelessWidget {
  const RatelSheet({super.key, this.title, required this.child, this.actions});

  final String? title;
  final Widget child;
  final List<Widget>? actions;

  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    required Widget child,
    List<Widget>? actions,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: context.surfaceC,
      showDragHandle: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.tokens.radiusLg),
        ),
      ),
      builder: (_) => RatelSheet(title: title, actions: actions, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          RatelSpacing.lg,
          RatelSpacing.md,
          RatelSpacing.lg,
          RatelSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: RatelSpacing.md),
                decoration: BoxDecoration(
                  color: context.borderC,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: RatelSpacing.md),
                child: Text(
                  title!,
                  style: TextStyle(
                    fontFamily: kDisplayFont,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: context.textC,
                  ),
                ),
              ),
            child,
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: RatelSpacing.md),
              ...actions!,
            ],
          ],
        ),
      ),
    );
  }
}
