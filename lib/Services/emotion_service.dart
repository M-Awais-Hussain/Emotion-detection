export 'emotion_service_stub.dart'
    if (dart.library.js_interop) 'emotion_service_web.dart'
    if (dart.library.io) 'emotion_service_native.dart';
