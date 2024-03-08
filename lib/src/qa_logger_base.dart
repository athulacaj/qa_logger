import 'dart:async';
import 'package:qa_logger/src/helper/fifo_que.dart';
import 'package:qa_logger/src/helper/request_node.dart';
import 'package:qa_logger/src/helper/server.dart';
import 'package:qa_logger/src/helper/util_functions.dart';
import 'package:qa_logger/src/interceptor/dio_interceptor.dart';
import 'package:qa_logger/src/logger/logger.dart';

/// The QaLogger class provides logging functionality for QA purposes.
class QaLogger {
  static QaLogger? _instance;
  static int _port = 3000;
  static int _wsPort = 8000;
  static int _logLimit = 100;
  late Server _wsServer;
  late LogHelper _logHelper;

  /// The requestStream is a broadcast stream that listens for requests.
  /// It is used to listen for requests and log them.
  static final StreamController<RequestNode> requestStream =
      StreamController<RequestNode>.broadcast();

  late FiFoQueue<RequestNode> requestQueue;

  /// Configures the QaLogger with the specified ports and log limit.
  ///
  /// [port] is the port number to start the server (default is 3000).
  /// [wsPort] is the WebSocket port number (default is 8000).
  /// [logLimit] is the maximum number of logs to keep in the queue (default is 100).
  static configure({int port = 3000, int wsPort = 8000, int logLimit = 100}) {
    _port = port;
    _wsPort = wsPort;
    _logLimit = logLimit;
  }

  /// Private constructor for the QaLogger class.
  QaLogger._() {
    requestQueue = FiFoQueue<RequestNode>(_logLimit);
    _wsServer = Server(requestQueue: requestQueue);
    _logHelper = LogHelper(wsServer: _wsServer, requestQueue: requestQueue);
    _wsServer.startWsServer(_wsPort);
    _wsServer.startExpressServer(_port);
  }

  /// Returns the singleton instance of the QaLogger class.
  factory QaLogger() {
    _instance ??= QaLogger._();
    return _instance!;
  }

  /// Returns the DioInterceptor for intercepting Dio requests.
  get dioInterceptor =>
      DioInterceptor(requestQueue: requestQueue, wsServer: _wsServer);

  /// Logs the specified [message].
  void log(String? message) {
    if (message != null) {
      _logHelper.log(message);
    }
  }

  /// Logs the specified [message] as an error.
  void logError(String? message) {
    if (message != null) {
      _logHelper.logError(message);
    }
  }

  /// Retrieves the logs history as HTML and invokes the provided callback function with the result.
  ///
  /// The [callback] function should take a single parameter of type [String], which represents the HTML result.
  void getLogsHistoryAsHtml(Function(String) callback) {
    String result = UtilFunctions().getHtmlWithInjectedData(requestQueue.value);
    callback(result);
  }
}
