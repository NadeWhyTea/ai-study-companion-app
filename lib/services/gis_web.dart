import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:js/js.dart';

// Conditional import for HTML element
import 'html_element_stub.dart'
if (dart.library.html) 'html_element_web.dart';

@JS('google.accounts.id')
external GoogleAccountsID get googleAccountsID;

@JS()
class GoogleAccountsID {
  external void initialize(GoogleIDInitializeOptions options);
  external void renderButton(dynamic element, dynamic options);
  external void prompt();
}

@JS()
@anonymous
class GoogleIDInitializeOptions {
  external String get client_id;
  external Function get callback;

  external factory GoogleIDInitializeOptions({
    required String client_id,
    required Function callback,
  });
}