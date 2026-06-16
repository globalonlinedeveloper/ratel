import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// On wide viewports (web/desktop) renders the app inside a centered phone-
/// sized frame so the mobile UI can be validated in a browser. On real narrow
/// screens (phones) it passes through full-screen, unchanged.
class MobileFrame extends StatelessWidget {
  const MobileFrame({super.key, required this.child});

  final Widget child;

  static const double _w = 390;
  static const double _h = 844;
  static const double _breakpoint = 540;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < _breakpoint) return child;
        final RatelTokens tk = context.tokens;
        final double avail =
            constraints.maxHeight.isFinite ? constraints.maxHeight : _h + 80;
        final double ph = (avail - 64).clamp(480.0, _h);
        return ColoredBox(
          color: tk.page,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: tk.border),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(29),
                    child: SizedBox(
                      width: _w,
                      height: ph,
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          size: Size(_w, ph),
                          padding: EdgeInsets.zero,
                          viewInsets: EdgeInsets.zero,
                          viewPadding: EdgeInsets.zero,
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: RatelSpacing.md),
                Text(
                  'Mobile preview · ${_w.round()}×${ph.round()} · real phones render full-screen',
                  style: TextStyle(color: tk.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
