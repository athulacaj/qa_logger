import 'dart:convert';

import 'package:qa_logger/src/helper/fifo_que.dart';

/// Represents a node in the request queue.
class RequestNode {
  final int _intId = FiFoQueue.total;

  /// Creates a new instance of [RequestNode].
  RequestNode();

  Map base = {};
  Map<String, dynamic> request = {};
  Map<String, dynamic> response = {};

  /// Returns the ID of the request node.
  int get id => _intId;

  /// Adds a key-value pair to the base map.
  void addBase(String key, dynamic value) {
    base[key] = value;
  }

  /// Adds a key-value pair to the request map.
  /// If the value is of type [Duration], it is converted to seconds before adding.
  void addRequest(String key, dynamic value) {
    if (value is Duration) {
      value = value.inSeconds;
    }
    request[key] = value;
  }

  /// Adds a key-value pair to the response map.
  void addResponse(String key, dynamic value) {
    response[key] = value;
  }

  /// Converts the request node to a JSON string.
  String toJson() {
    Map<String, dynamic> body = {
      'id': _intId,
      ...base,
      'request': request,
      'response': response,
    };
    return jsonEncode(body);
  }

  /// Converts the request node to a map.
  Map<String, dynamic> toMap() {
    Map<String, dynamic> body = {
      'id': _intId,
      ...base,
      'request': request,
      'response': response,
    };
    return body;
  }

  @override
  String toString() {
    return "${request['method']}: ${request['uri']}";
  }
}
