import 'dart:html' as html;

class WebWindow {
  static dynamic get currentUrl => html.window.location.href;
  static dynamic get origin => html.window.location.origin;
}
