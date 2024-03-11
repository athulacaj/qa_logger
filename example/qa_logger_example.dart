import 'package:dio/dio.dart';
import 'package:qa_logger/qa_logger.dart';

void main() {
  /// (Optional) To configure the QaLogger with the specified ports and log limit

  // QaLogger.configure(port: 3001, wsPort: 8001, logLimit: 400);

  /// your Dio instance
  Dio dio = Dio();

  /// add the QaLogger DioInterceptor to the Dio instance
  dio.interceptors.add(QaLogger().dioInterceptor);

  /// call google.com using Dio
  dio.get('https://www.google.com');

  /// call a dummy API using Dio
  dio.get('https://dummy.restapiexample.com/api/v1/employees');

  QaLogger().log('This is a log message');
  QaLogger().logError('This is an error message');

  // now opent the browser and go to http://localhost:3000 to see the network  calls and logs
}
