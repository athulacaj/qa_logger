part of qa_logger;

class QaLogger {
  static QaLogger? _instance;
  final WSServer _wsServer = WSServer();
  final LogHelper _logHelper = LogHelper();

  QaLogger._() {
    _wsServer.startWsServer();
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
