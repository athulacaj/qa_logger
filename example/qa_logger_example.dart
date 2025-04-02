import 'package:dio/dio.dart';
import 'package:qa_logger/qa_logger.dart';

Future<void> main() async {
  /// (Optional) To configure the QaLogger with the specified ports and log limit

  // QaLogger.configure(port: 3001, wsPort: 8001, logLimit: 400);

  /// your Dio instance
  Dio dio = Dio();

  /// add the QaLogger DioInterceptor to the Dio instance
  dio.interceptors.add(QaLogger().dioInterceptor);

  /// call a dummy API using Dio
  dio.get('https://pub.dev');
  dio.get('https://jsonplaceholder.typicode.com/todos/1');

  QaLogger().log('This is a log message');
  QaLogger().logError('This is an error message');

  print(
      "open the browser and go to http://localhost:3000 to see the network calls and logs");

  for (int i = 2; i < 10; i++) {
    await Future.delayed(Duration(seconds: 1));
    dio.get('https://jsonplaceholder.typicode.com/todos/$i');
  }

  // now opent the browser and go to http://localhost:3000 to see the network  calls and logs
}
