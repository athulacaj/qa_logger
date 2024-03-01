import 'dart:io';
import 'dart:math';

import 'package:flutter_express/flutter_express.dart';
import 'package:flutter_express/middlewares.dart';
import 'package:qa_logger/src/web/build/output_css.dart';
import 'package:qa_logger/src/web/build/output_html.dart';
import 'package:qa_logger/src/web/build/output_js.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

class WSServer {
  static WSServer? _instance;
  dynamic _webSocketChannel;
  int tryCount = 0;
  late int _wsPort;

  WSServer._() {
    getAddress();
  }

  factory WSServer() {
    _instance ??= WSServer._();
    return _instance!;
  }

  List<String> ipAddresses = [];

  List<String> getIpAddress() {
    return ipAddresses;
  }

  int getRandomPort() {
    final Random random = Random();
    return 8010 + random.nextInt(200);
  }

  String ipIpAddress = '';
  List<String> ipAddressList = [];

  Future<void> getAddress() async {
    print('printAddress');
    final interfaces = await NetworkInterface.list(
        includeLoopback: false, type: InternetAddressType.IPv4);
    print('interfaces: $interfaces');
    for (NetworkInterface interface in interfaces) {
      if (interface.name.contains('wlan') || interface.name.contains('en')) {
        for (InternetAddress addr in interface.addresses) {
          if (addr.type.name == 'IPv4') {
            ipAddresses.add(addr.address);
            print('ip has address ${addr.address}');
            ipIpAddress = addr.address;
          }
        }
      }
    }
    // NetworkInterface interface = interfaces.first;
    // ipIpAddress = interface.addresses.first.address;
  }

  void startWsServer(int wsPort) {
    _wsPort = wsPort;
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
    }).catchError((e) {
      if (tryCount < 2) {
        tryCount++;
        getRandomPort();
        startWsServer(getRandomPort());
      }
      print('qa_logger error: $e');
    });
  }

  void startExpressServer(int port) {
    final app = FlutterExpress();

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
        'ws': 'ws://$ipIpAddress:$_wsPort',
        'wsPort': _wsPort,
      });
    });

    app.listen(port, (server) {
      print('Server is running on port ${server.port}');
    });
  }

  void sendWsMessage(String message) {
    if (_webSocketChannel != null) _webSocketChannel!.sink.add(message);
  }
}


// adb forward tcp:8081 tcp:8081
// adb forward tcp:3000 tcp:3000
// adb forward --remove tcp:300