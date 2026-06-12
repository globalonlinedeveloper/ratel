import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/art.dart';
import 'package:ratel/widgets/ratel_art.dart';

/// A valid 1x1 transparent PNG (kTransparentImage).
const List<int> _kPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

const _base = 'https://unit.test/storage/v1/object/public/art/';

void main() {
  setUp(() {
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
    Art.instance.debugSet(paths: {}, publicBase: _base, bundled: {});
  });

  tearDown(() {
    Art.instance.debugSet(paths: {}, publicBase: _base, bundled: {});
  });

  group('Art resolver', () {
    test('urlFor maps manifest names to public URLs, null otherwise', () {
      Art.instance.debugSet(paths: {'emo_happy': 'emotions/emo_happy.webp'});
      expect(Art.instance.urlFor('emo_happy'),
          '${_base}emotions/emo_happy.webp');
      expect(Art.instance.urlFor('nope'), isNull);
      expect(Art.instance.has('emo_happy'), isTrue);
      expect(Art.instance.has('nope'), isFalse);
    });

    test('bundled-first: a bundled name never resolves to a URL', () {
      Art.instance.debugSet(
        paths: {'emo_happy': 'emotions/emo_happy.webp'},
        bundled: {'emo_happy': 'assets/images/ratel-happy.webp'},
      );
      expect(Art.instance.urlFor('emo_happy'), isNull);
      expect(Art.instance.bundledFor('emo_happy'),
          'assets/images/ratel-happy.webp');
      expect(Art.instance.has('emo_happy'), isTrue);
    });
  });

  group('RatelArt widget', () {
    testWidgets('unknown name renders the bundled fallback, no network',
        (tester) async {
      await tester.pumpWidget(
          MaterialApp(home: const RatelArt('totally_unknown')));
      final img = tester.widget<Image>(find.byType(Image));
      expect(img.image, isA<AssetImage>());
      expect((img.image as AssetImage).assetName,
          'assets/images/ratel-idle.webp');
    });

    testWidgets('bundled name renders from the bundle even when remote too',
        (tester) async {
      Art.instance.debugSet(
        paths: {'emo_proud': 'emotions/emo_proud.webp'},
        bundled: {'emo_proud': 'assets/images/ratel-happy.webp'},
      );
      await tester.pumpWidget(MaterialApp(home: const RatelArt('emo_proud')));
      final img = tester.widget<Image>(find.byType(Image));
      expect(img.image, isA<AssetImage>());
      expect((img.image as AssetImage).assetName,
          'assets/images/ratel-happy.webp');
    });

    testWidgets('manifest name loads from the public storage URL',
        (tester) async {
      debugNetworkImageHttpClientProvider = () => _Client(200, _kPng);
      Art.instance.debugSet(paths: {'emo_happy': 'emotions/emo_happy.webp'});
      await tester.pumpWidget(
          MaterialApp(home: const RatelArt('emo_happy')));
      final img = tester.widget<Image>(find.byType(Image));
      expect(img.image, isA<NetworkImage>());
      expect((img.image as NetworkImage).url,
          '${_base}emotions/emo_happy.webp');
      // settle the in-flight fetch/decode microtasks before teardown
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      debugNetworkImageHttpClientProvider = null; // invariant check pre-tearDown
    });

    testWidgets('remote failure falls back to the bundled static (404)',
        (tester) async {
      debugNetworkImageHttpClientProvider = () => _Client(404, const <int>[]);
      Art.instance.debugSet(paths: {'emo_sad': 'emotions/emo_sad.webp'});
      await tester.pumpWidget(MaterialApp(home: const RatelArt('emo_sad')));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      // errorBuilder keeps the outer Image.network widget and nests the
      // fallback inside it -> assert the AssetImage twin appeared.
      final images = tester.widgetList<Image>(find.byType(Image)).toList();
      final fallbacks =
          images.where((i) => i.image is AssetImage).toList();
      expect(fallbacks, hasLength(1),
          reason: 'errorBuilder must swap in the bundled fallback');
      expect((fallbacks.single.image as AssetImage).assetName,
          'assets/images/ratel-idle.webp');
      debugNetworkImageHttpClientProvider = null; // invariant check pre-tearDown
    });
  });
}

// ---- minimal fake HTTP stack (NetworkImage's dart:io path) ----

// NOTE: NetworkImage holds a STATIC shared HttpClient, so a per-test
// HttpOverrides.global is ignored after the first load -- the per-load
// debugNetworkImageHttpClientProvider hook is the supported seam.

class _Client implements HttpClient {
  _Client(this.status, this.body);
  final int status;
  final List<int> body;
  @override
  bool autoUncompress = true;
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _Req(status, body);
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('HttpClient.${invocation.memberName}');
}

class _Req implements HttpClientRequest {
  _Req(this.status, this.body);
  final int status;
  final List<int> body;
  @override
  final HttpHeaders headers = _Headers();
  @override
  Future<HttpClientResponse> close() async => _Resp(status, body);
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('HttpClientRequest.${invocation.memberName}');
}

class _Resp extends Stream<List<int>> implements HttpClientResponse {
  _Resp(this.statusCode, this.body);
  @override
  final int statusCode;
  final List<int> body;
  @override
  int get contentLength => body.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(void Function(List<int>)? onData,
          {Function? onError, void Function()? onDone, bool? cancelOnError}) =>
      Stream<List<int>>.fromIterable(<List<int>>[body]).listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('HttpClientResponse.${invocation.memberName}');
}

class _Headers implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
