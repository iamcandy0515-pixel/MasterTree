// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class WebUtils {
  static void reloadPage() {
    html.window.location.reload();
  }
}
