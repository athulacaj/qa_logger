import 'dart:convert';

import 'package:qa_logger/src/helper/fifo_que.dart';

class RequestNode {
  final int _intId = FiFoQueue.total;
  RequestNode();

  Map base = {};
  Map<String, dynamic> request = {};
  Map<String, dynamic> response = {};

  int get id => _intId;

  addBase(String key, dynamic value) {
    base[key] = value;
  }

  addRequest(String key, dynamic value) {
    if (value is Duration) {
      value = value.inSeconds;
    }
    request[key] = value;
  }

  addResponse(String key, dynamic value) {
    response[key] = value;
  }

  String toJson() {
    Map<String, dynamic> body = {
      'id': _intId,
      ...base,
      'request': request,
      'response': response,
    };
    return jsonEncode(body);
  }

  Map<String, dynamic> toMap() {
    response['data'] = response['data']?.toString();
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
