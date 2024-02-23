part of qa_logger;

class WSServer {
  static final WSServer _instance = WSServer._();
  dynamic _webSocketChannel;

  WSServer._() {
    wsPort = getRandomPort();
    getAddress();
  }

  factory WSServer() {
    return _instance;
  }

  List<String> ipAddresses = [];
  late int wsPort;

  List<String> getIpAddress() {
    return ipAddresses;
  }

  int getRandomPort() {
    final Random random = Random();
    return 8002 + random.nextInt(8201 - 8002);
  }

  String ipIpAddress = '';
  List<String> ipAddressList = [];

  Future<void> getAddress() async {
    print('printAddress');
    final interfaces = await NetworkInterface.list(
        includeLoopback: false, type: InternetAddressType.IPv4);
    print('interfaces: $interfaces');
    for (NetworkInterface interface in interfaces) {
      for (InternetAddress addr in interface.addresses) {
        if (addr.type.name == 'IPv4') {
          ipAddresses.add(addr.address);
          print('ip has address ${addr.address}');
        }
      }
    }
    NetworkInterface interface = interfaces.first;
    ipIpAddress = interface.addresses.first.address;
  }

  void startWsServer() {
    var handler = webSocketHandler((dynamic webSocket) {
      _webSocketChannel = webSocket;
      webSocket.stream.listen((message) {
        print("message from ws: $message");
      });
    });

    // get a random port from 8002 to 8200
    shelf_io.serve(handler, InternetAddress.anyIPv4, wsPort).then((server) {
      print('Serving at ws://${server.address.host}:${server.port}');
      getAddress();
      // get my ip address
    });
    final app = FlutterExpress();
    const portNumber = 3000;

    app.use("*", [cors()]);

    app.get('/', (req, res) async {
      String contents = htmlString;
      res.send(contents);
    });
    app.get('/_support.css', (req, res) async {
      String contents = cssString;
      res.sendTextFile(contents, 'css');
    });
    app.get('/_support.js', (req, res) async {
      String contents = jsString;
      res.sendTextFile(contents, 'javascript');
    });

    app.get('/ip', (req, res) async {
      res.json({
        'ip': ipIpAddress,
        'port': wsPort,
        'ws': 'ws://$ipIpAddress:$wsPort',
      });
    });

    app.listen(portNumber, (server) {
      print('Server is running on port ${server.port}');
    });
  }

  void sendWsMessage(String message) {
    if (_webSocketChannel != null) _webSocketChannel!.sink.add(message);
  }
}


// adb forward tcp:8081 tcp:8081
// adb forward tcp:3000 tcp:3000
