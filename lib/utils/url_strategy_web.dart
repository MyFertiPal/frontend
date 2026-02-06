import 'package:flutter_web_plugins/url_strategy.dart';

void setAppUrlStrategy() {
  setUrlStrategy(const HashUrlStrategy());
}
