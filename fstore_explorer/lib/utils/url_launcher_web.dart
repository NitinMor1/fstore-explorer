import 'dart:html' as html;

/// Web implementation of openUrl.
Future<void> openUrl(String urlString) async {
  html.window.open(urlString, '_blank');
}
