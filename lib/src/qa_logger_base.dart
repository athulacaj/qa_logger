part of qa_logger;

class NetworkLogger {
  static final NetworkLogger _instance = NetworkLogger._();
  final WSServer _wsServer = WSServer();

  NetworkLogger._() {
    _wsServer.startWsServer();
    // ping();
  }
  factory NetworkLogger() {
    return _instance;
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
