part of qa_logger;

class QaLogger {
  static QaLogger? _instance;
  final WSServer _wsServer = WSServer();
  final LogHelper _logHelper = LogHelper();
  static int _port = 3000;
  static int _wsPort = 8000;

  /// port to start the server
  /// default is 3000
  static configure({int port = 3000, int wsPort = 8000}) {
    _port = port;
    _wsPort = wsPort;
  }

  QaLogger._() {
    _wsServer.startWsServer(_wsPort);
    _wsServer.startExpressServer(_port);
  }
  factory QaLogger() {
    _instance ??= QaLogger._();
    return _instance!;
  }

  get dioInterceptor => DioInterceptor();

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
