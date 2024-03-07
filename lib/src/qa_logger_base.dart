import 'dart:async';
import 'package:qa_logger/src/helper/fifo_que.dart';
import 'package:qa_logger/src/helper/request_node.dart';
import 'package:qa_logger/src/helper/server.dart';
import 'package:qa_logger/src/interceptor/dio_interceptor.dart';
import 'package:qa_logger/src/logger/logger.dart';

class QaLogger {
  static QaLogger? _instance;
  static int _port = 3000;
  static int _wsPort = 8000;
  static int _logLimit = 20;
  late Server _wsServer;
  late LogHelper _logHelper;
  static final StreamController<RequestNode> requestStream =
      StreamController<RequestNode>.broadcast();

  late FiFoQueue<RequestNode> requestQueue;

  /// port to start the server
  /// default is 3000
  static configure({int port = 3000, int wsPort = 8000, int logLimit = 20}) {
    _port = port;
    _wsPort = wsPort;
    _logLimit = logLimit;
  }

  QaLogger._() {
    requestQueue = FiFoQueue<RequestNode>(_logLimit);
    _wsServer = Server(requestQueue: requestQueue);
    _logHelper = LogHelper(wsServer: _wsServer, requestQueue: requestQueue);
    _wsServer.startWsServer(_wsPort);
    _wsServer.startExpressServer(_port);
  }
  factory QaLogger() {
    _instance ??= QaLogger._();
    return _instance!;
  }

  get dioInterceptor =>
      DioInterceptor(requestQueue: requestQueue, wsServer: _wsServer);

  void log(String? message) {
    if (message != null) {
      _logHelper.log(message);
    }
  }

  void logError(String? message) {
    if (message != null) {
      _logHelper.logError(message);
    }
  }

  void ping() {
    // ervery one second send a ping message to the client
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      _wsServer.sendWsMessage('ipaddress: ${_wsServer.getIpAddress()}');
      return true;
    });
  }
}
