import 'package:flutter/material.dart';

import '../art.dart';

/// Renders a named art cell: bundled-first, then the remote manifest
/// (Supabase Storage public URL — cached by the engine's ImageCache and the
/// browser's HTTP cache on web), and on ANY miss or load failure the bundled
/// static mascot [fallbackAsset]. A screen can never go blank or crash
/// because of remote art (offline-first preserved).
class RatelArt extends StatelessWidget {
  const RatelArt(
    this.name, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.fallbackAsset = 'assets/images/ratel-idle.webp',
  });

  final String name;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String fallbackAsset;

  Widget _fallback() =>
      Image.asset(fallbackAsset, width: width, height: height, fit: fit);

  @override
  Widget build(BuildContext context) {
    final bundled = Art.instance.bundledFor(name);
    if (bundled != null) {
      return Image.asset(bundled, width: width, height: height, fit: fit);
    }
    final url = Art.instance.urlFor(name);
    if (url == null) return _fallback();
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => _fallback(),
    );
  }
}
