import 'dart:io';
import 'dart:math';

import 'package:flutter_express/flutter_express.dart';
import 'package:flutter_express/middlewares.dart';
import 'package:qa_logger/src/helper/fifo_que.dart';
import 'package:qa_logger/src/helper/request_node.dart';
import 'package:qa_logger/src/helper/util_functions.dart';

import 'package:qa_logger/src/web/build/output_css.dart';
import 'package:qa_logger/src/web/build/output_html.dart';
import 'package:qa_logger/src/web/build/output_js.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

/// Represents a server that handles WebSocket and Express server functionality.
class Server {
  static Server? _instance;
  dynamic _webSocketChannel;
  int tryCount = 0;
  late int _wsPort;
  late FiFoQueue<RequestNode> requestQueue;

  /// Private constructor for the Server class.
  Server._(this.requestQueue) {
    getAddress();
  }

  /// Factory constructor for the Server class.
  factory Server({required FiFoQueue<RequestNode> requestQueue}) {
    _instance ??= Server._(requestQueue);
    return _instance!;
  }

  List<String> ipAddresses = [];

  /// Returns a list of IP addresses.
  List<String> getIpAddress() {
    return ipAddresses;
  }

  /// Generates a random port number.
  int getRandomPort() {
    final Random random = Random();
    return 8010 + random.nextInt(200);
  }

  String ipIpAddress = '';
  List<String> ipAddressList = [];

  /// Retrieves the IP address of the server.
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
  }

  /// Starts the WebSocket server.
  void startWsServer(int wsPort) {
    _wsPort = wsPort;
    // var handler = webSocketHandler((ConnectionCallback webSocket) {
    //   _webSocketChannel = webSocket;
    //   webSocket.stream.listen((message) {
    //     print("message from ws: $message");
    //   });
    // });

      var handler = webSocketHandler((webSocket, _) {
            _webSocketChannel = webSocket;
    webSocket.stream.listen((message) {
      // webSocket.sink.add('echo $message');
        print("message from ws: $message");
    });
  });

    // get a random port from 8002 to 8200
    shelf_io.serve(handler, InternetAddress.anyIPv4, wsPort).then((server) {
      print('Serving at ws://${server.address.host}:${server.port}');
      getAddress();
    }).catchError((e) {
      if (tryCount < 2) {
        tryCount++;
        getRandomPort();
        startWsServer(getRandomPort());
      }
      print('qa_logger error: $e');
    });
  }

  /// Starts the Express server.
  Future<void> startExpressServer(int port) async {
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
        'shareUrl': 'http://$ipIpAddress:$port/',
        'ws': 'ws://$ipIpAddress:$_wsPort',
        'wsPort': _wsPort,
      });
    });
    app.get("/history", (req, res) {
      List<RequestNode> history = requestQueue.value;
      List dataList = history.map((e) => e.toMap()).toList();
      res.json(dataList);
    });

    app.get("/download", (req, res) {
      String result =
          UtilFunctions().getHtmlWithInjectedData(requestQueue.value);
      res.json({"data": result});
    });

    app.listen(port, () {
      print('Server is running on port $port');
    });
  }

  /// Sends a message through the WebSocket channel.
  void sendWsMessage(String message) {
    if (_webSocketChannel != null) _webSocketChannel!.sink.add(message);
  }
}
