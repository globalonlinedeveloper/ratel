import 'dart:convert';
import 'dart:js_interop';

@JS('ratelLogEvent')
external void _ratelLogEvent(JSString name, JSString paramsJson);

/// Forwards an event to the gtag bridge defined in web/index.html.
void logEvent(String name, Map<String, Object?> params) {
  try {
    _ratelLogEvent(name.toJS, jsonEncode(params).toJS);
  } catch (_) {}
}
