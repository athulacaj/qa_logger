import 'dart:convert';

import 'package:qa_logger/src/helper/request_node.dart';
import 'package:qa_logger/src/web/build/output_css.dart';
import 'package:qa_logger/src/web/build/output_html.dart';
import 'package:qa_logger/src/web/build/output_js.dart';

class UtilFunctions {
  const UtilFunctions();

  /// Returns an HTML string with injected data.
  ///
  /// This method takes a list of [history] objects and generates an HTML string
  /// with injected data. It first appends the [htmlString] to the [result] string,
  /// then converts the [history] list to a list of maps using the `toMap` method
  /// of each [RequestNode] object. The resulting list is then encoded as JSON and
  /// assigned to the [injectData] variable.

  String getHtmlWithInjectedData(List<RequestNode> history) {
    String result = '';
    result += htmlString;
    List dataList = history.map((e) {
      return e.toMap();
    }).toList();
    final injectData = "var injectedData = ${jsonEncode(dataList)};";

    result = result.replaceFirst('<script src="./_support.js"></script>',
        '<script>$injectData$jsString</script>');
    result = result.replaceFirst(
        '<link rel="stylesheet" href="./_support.css">',
        '<style>$cssString</style>');

    return result;
  }
}
