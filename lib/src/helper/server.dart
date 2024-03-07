import 'dart:io';
import 'dart:math';

import 'package:flutter_express/flutter_express.dart';
import 'package:flutter_express/middlewares.dart';
import 'package:qa_logger/src/helper/fifo_que.dart';
import 'package:qa_logger/src/helper/request_node.dart';

import 'package:qa_logger/src/web/build/output_css.dart';
import 'package:qa_logger/src/web/build/output_html.dart';
import 'package:qa_logger/src/web/build/output_js.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

class Server {
  static Server? _instance;
  dynamic _webSocketChannel;
  int tryCount = 0;
  late int _wsPort;
  late FiFoQueue<RequestNode> requestQueue;

  Server._(this.requestQueue) {
    getAddress();
  }

  factory Server({required FiFoQueue<RequestNode> requestQueue}) {
    _instance ??= Server._(requestQueue);
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

  Future<void> startExpressServer(int port) async {
    final app = FlutterExpress();

    app.use("*", [cors()]);

    app.get('/', (req, res) async {
      //  var mapUrl = '${p.toUri(p.relative(dartPath, from: _root)).path}'
      //     '.browser_test.dart.js.map';
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
    app.get("/history", (req, res) {
      List<RequestNode> history = requestQueue.value;
      List dataList = history.map((e) => e.toMap()).toList();
      res.json(dataList);
    });

    app.listen(port, () {
      print('Server is running on port $port');
    });

    // var app = Router();

    // app.get('/', (Request request) {
    //   String contents = htmlString;
    //   return Response.ok(contents, headers: {
    //     'Content-Type': 'text/html',
    //   });
    // });

    // app.get('/_support.css', (Request request, String user) {
    //   String contents = cssString;
    //   return Response.ok(contents, headers: {
    //     'mime-type': 'text/css', // 'text/css
    //     'Content-Type': 'text/css',
    //   });
    // });
    // app.get('/_support.js', (Request request, String user) {
    //   String contents = jsString;
    //   return Response.ok(contents, headers: {
    //     'Content-Type': 'text/javascript',
    //   });
    // });
    // app.get('/user/<user>', (Request request, String user) {
    //   return Response.ok('hello $user');
    // });

    // // var server = await io.serve(app, 'localhost', port);
    // // print('Serving at http://${server.address.host}:${server.port}');

    // var handler = const Pipeline()
    //     .addMiddleware(logRequests())
    //     .addHandler((Request request) {
    //   List<RequestNode> history = requestQueue.value;
    //   List dataList = [];
    //   for (var i = 0; i < history.length; i++) {
    //     final data = history[i].toMap();
    //     dataList.add(data);
    //   }
    //   return Response.ok(jsonEncode(dataList), headers: {
    //     'Content-Type': 'application/json',
    //   });
    // });

    // var server = await shelf_io.serve(handler, 'localhost', port);

    // // Enable content compression
    // server.autoCompress = true;

    // print('Serving at http://${server.address.host}:${server.port}');
  }

  void sendWsMessage(String message) {
    if (_webSocketChannel != null) _webSocketChannel!.sink.add(message);
  }
}
