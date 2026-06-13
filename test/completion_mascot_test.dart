import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/art.dart';
import 'package:ratel/widgets/completion_mascot.dart';
import 'package:ratel/widgets/mascot_anim.dart';
import 'package:ratel/widgets/ratel_art.dart';

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

  testWidgets('perfect + manifest has emo_proud -> remote emotion art',
      (tester) async {
    debugNetworkImageHttpClientProvider = () => _Client(200, _kPng);
    Art.instance.debugSet(paths: {'emo_proud': 'emotions/emo_proud.webp'});
    await tester.pumpWidget(
        const MaterialApp(home: CompletionMascot(perfect: true)));
    expect(find.byType(RatelArt), findsOneWidget);
    final img = tester.widget<Image>(find.byType(Image));
    expect(img.image, isA<NetworkImage>());
    expect((img.image as NetworkImage).url,
        '${_base}emotions/emo_proud.webp');
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    debugNetworkImageHttpClientProvider = null;
  });

  testWidgets('offline (empty manifest) -> bundled action anim, no remote',
      (tester) async {
    Art.instance.debugSet(paths: {});
    await tester.pumpWidget(
        const MaterialApp(home: CompletionMascot(perfect: false)));
    expect(find.byType(RatelArt), findsNothing);
    expect(find.byType(RatelActionAnim), findsOneWidget);
  });
}

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
