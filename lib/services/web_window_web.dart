import 'dart:html' as html;

class WebWindow {
  static String get currentUrl => html.window.location.href;
  static String get origin => html.window.location.origin;
}
