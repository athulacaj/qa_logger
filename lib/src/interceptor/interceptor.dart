part of qa_logger;

List<RequestNode> requesttList = [];
// create a stream for the request
final requestStream = StreamController<RequestNode>.broadcast();
// listen to the request stream for the changes

class RequestNode {
  final int _intId;
  RequestNode() : _intId = requesttList.length {
    requesttList.add(this);
  }

  Map base = {};
  Map<String, dynamic> request = {};
  Map<String, dynamic> response = {};

  int get id => _intId;

  addBase(String key, dynamic value) {
    base[key] = value;
  }

  addRequest(String key, dynamic value) {
    if (value is Duration) {
      value = value.inSeconds;
    }
    request[key] = value;
  }

  addResponse(String key, dynamic value) {
    response[key] = value;
  }

  String toJson() {
    Map<String, dynamic> body = {
      'id': _intId,
      ...base,
      'request': request,
      'response': response,
    };
    return jsonEncode(body);
  }

  @override
  String toString() {
    return "${request['method']}: ${request['uri']}";
  }
}

class QAInterceptor extends Interceptor {
  static final instance = QAInterceptor._();
  final WSServer _wsServer = WSServer();

  QAInterceptor._() {
    _wsServer.startWsServer();
    requestStream.stream.listen((RequestNode request) {
      print("stream qa logs request : $request");
      _wsServer.sendWsMessage(request.toJson());
    });
  }

  factory QAInterceptor() => instance;

  final request = true;
  final requestHeader = true;
  final requestBody = true;
  final responseHeader = true;
  final responseBody = true;
  final error = true;
  final logPrint = _debugPrint;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    RequestNode requestNode = RequestNode();
    requestNode.addBase('type', 'request');
    requestNode.addRequest('uri', options.uri.toString());
    requestNode.addRequest("timestamp", DateTime.now().toIso8601String());
    //options.headers;

    if (request) {
      requestNode.addRequest('method', options.method);
      requestNode.addRequest('responseType', options.responseType.toString());
      requestNode.addRequest('followRedirects', options.followRedirects);
      requestNode.addRequest('contentType', options.contentType);
      requestNode.addRequest(
          'persistentConnection', options.persistentConnection);
      requestNode.addRequest('connectTimeout', options.connectTimeout);
      requestNode.addRequest('sendTimeout', options.sendTimeout);
      requestNode.addRequest('receiveTimeout', options.receiveTimeout);
      requestNode.addRequest(
        'receiveDataWhenStatusError',
        options.receiveDataWhenStatusError,
      );
      requestNode.addRequest('extra', options.extra);
    }
    if (requestHeader) {
      logPrint('headers:');
      // requestNode.addRequest('headers', options.headers);
      // options.headers.forEach((key, v) => _printKV(' $key', v));
      Map headers = {};
      options.headers.forEach((key, v) => headers[key] = v);
      requestNode.addRequest('headers', headers);
    }
    if (requestBody) {
      // logPrint('data:');
      // _printAll(options.data);
      if (options.data is FormData) {
        FormData formData = options.data;
        final boundary = formData.boundary;
        String result = '';
        for (var element in formData.fields) {
          result += "$boundary\n";
          result += "Content-Disposition: form-data; name=\"${element.key}\"\n";
          result += "${element.value}\n";
          result += "--$boundary--\n";
        }

        // data['type'] = 'form-data';
        requestNode.addRequest('data', {
          'type': 'form-data',
          'boundary': boundary,
          'curlStr': formData.fields
              .map((e) => "--form '${e.key}=${e.value}'\\")
              .join(),
          'result': result,
        });
      } else {
        requestNode.addRequest('data', options.data);
      }
    }
    logPrint('');

    // print("qa logs request: ${requestNode.toJson()}");
    // print("qa logs request: $requesttList");
    requestStream.sink.add(requestNode);
    options.extra['qa_logs_id'] = requestNode.id;

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    logPrint('*** Response ***');
    _addResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (error) {
      logPrint('*** DioException ***:');
      logPrint('uri: ${err.requestOptions.uri}');
      logPrint('$err');
      if (err.response != null) {
        _addResponse(err.response!);
      }
      logPrint('');
    }

    handler.next(err);
  }

  void _addResponse(Response response) {
    _printKV('uri', response.requestOptions.uri);
    RequestNode requestNode =
        requesttList[response.requestOptions.extra['qa_logs_id']];

    Duration duration = DateTime.now()
        .difference(DateTime.parse(requestNode.request['timestamp']));
    requestNode.addBase('type', 'response');
    requestNode.addResponse('statusCode', response.statusCode);
    requestNode.addResponse('duration', duration.inMilliseconds);

    requestStream.sink.add(requestNode);

    if (responseHeader) {
      if (response.isRedirect == true) {
        requestNode.addResponse('redirect', response.realUri.toString());
      }

      Map headers = {};
      response.headers.forEach((key, v) => headers[key] = v);
      requestNode.addResponse('headers', headers);
    }
    if (responseBody) {
      if (response.data is String) {
        requestNode.addResponse('data', response.data);
      } else {
        requestNode.addResponse('data', response.data);
      }
      // logPrint('Response Text:');
      // _printAll(response.toString());
    }
    logPrint('');
  }

  void _printKV(String key, Object? v) {
    logPrint('$key: $v');
  }

  void _printAll(msg) {
    msg.toString().split('\n').forEach(logPrint);
  }
}

void _debugPrint(Object? object) {
  assert(() {
    print(object);
    return true;
  }());
}
