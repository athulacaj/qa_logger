import 'package:dio/dio.dart';
import 'package:qa_logger/src/helper/fifo_que.dart';
import 'package:qa_logger/src/helper/request_node.dart';
import 'package:qa_logger/src/helper/server.dart';
import 'package:qa_logger/src/qa_logger_base.dart';

class DioInterceptor extends Interceptor {
  // static final instance = DioInterceptor._();
  final Server wsServer;
  late FiFoQueue<RequestNode> requestQueue;

  DioInterceptor({required this.requestQueue, required this.wsServer}) {
    QaLogger.requestStream.stream.listen((RequestNode request) {
      print("stream qa logs request : $request");
      wsServer.sendWsMessage(request.toJson());
    });
  }

  // factory DioInterceptor() => instance;

  final request = true;
  final requestHeader = true;
  final requestBody = true;
  final responseHeader = true;
  final responseBody = true;
  final error = true;

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
      Map headers = {};
      options.headers.forEach((key, v) => headers[key] = v);
      requestNode.addRequest('headers', headers);
    }
    if (requestBody) {
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

    QaLogger.requestStream.sink.add(requestNode);
    options.extra['qa_logs_id'] = requestNode.id;

    requestQueue.add(requestNode);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    _addResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (error) {
      // logPrint('*** DioException ***:');
      // logPrint('uri: ${err.requestOptions.uri}');
      // logPrint('$err');
      if (err.response != null) {
        _addResponse(err.response!);
      }
    }

    handler.next(err);
  }

  void _addResponse(Response response) {
    try {
      RequestNode? requestNode =
          requestQueue.getItem(response.requestOptions.extra['qa_logs_id']);

      if (requestNode == null) {
        return;
      }

      Duration duration = DateTime.now()
          .difference(DateTime.parse(requestNode.request['timestamp']));
      requestNode.addBase('type', 'response');
      requestNode.addResponse('statusCode', response.statusCode);
      requestNode.addResponse('duration', duration.inMilliseconds);

      QaLogger.requestStream.sink.add(requestNode);

      Map headers = {};
      if (responseHeader) {
        if (response.isRedirect == true) {
          requestNode.addResponse('redirect', response.realUri.toString());
        }
        response.headers.forEach((key, v) => headers[key] = v);
        requestNode.addResponse('headers', headers);
      }
      if (responseBody) {
        if (response.data is String) {
          // escape ` character
          String escapedData = response.data;
          // if content-type:text/html;
          if (headers['content-type'].first.contains('text/html')) {
            escapedData =
                "<pre>${escapedData.replaceAll('<', '&lt;').replaceAll('>', '&gt;')}</pre>";
          }

          requestNode.addResponse('data', escapedData);
        } else {
          requestNode.addResponse('data', response.data);
        }
      }
    } catch (e) {
      print(e);
    }
  }
}
