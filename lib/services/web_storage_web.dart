import 'dart:html' as html;

class WebStorage {
  static String? getItem(String key) => html.window.localStorage[key];
  static void setItem(String key, String value) => html.window.localStorage[key] = value;
  static void removeItem(String key) => html.window.localStorage.remove(key);
}
