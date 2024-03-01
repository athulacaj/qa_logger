import 'dart:convert';

import 'package:qa_logger/qa_logger.dart';
import 'package:qa_logger/src/helper/server.dart';

class LogNode {
  final int _intId;
  static int _intIdCounter = 0;
  LogNode() : _intId = _intIdCounter {
    _intIdCounter++;
  }

  Map base = {};
  Map<String, dynamic> request = {};
  Map<String, dynamic> response = {};

  int get id => _intId;

  addBase(String key, dynamic value) {
    base[key] = value;
  }

  String toJson() {
    Map<String, dynamic> body = {
      'id': _intId,
      ...base,
    };
    return jsonEncode(body);
  }

  @override
  String toString() {
    return "${request['method']}: ${request['uri']}";
  }
}

class LogHelper {
  final WSServer _wsServer = WSServer();

  makeLogPayload(String message, String type) {
    final request = RequestNode();
    request.addBase('type', 'log');
    request.addBase('message', message);
    request.addBase('logType', type);
    request.addBase('timestamp', DateTime.now().toIso8601String());
    return request;
  }

  void log(String message) {
    _wsServer.sendWsMessage(makeLogPayload(message, 'log').toJson());
  }

  void logError(String message) {
    _wsServer.sendWsMessage(makeLogPayload(message, 'error').toJson());
  }
}
