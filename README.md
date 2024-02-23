# qa_logs

`qa_logs` is a Dart package that provides a simple and efficient way to monitor and log network calls in your application. It's an essential tool for debugging and quality assurance.

## Features

- Easy integration with Dio
- Detailed logging of network requests and responses
- Helps in identifying network-related issues

## Installation

Add `qa_logs` to your `pubspec.yaml` file:

```yaml
dependencies:
  qa_logs: ^1.0.0
```

Then run `flutter pub get`.

## Usage

Import `qa_logs` in your Dart file:

```dart
import 'package:qa_logs/qa_logs.dart';
```

Add the `QAInterceptor` to your Dio instance:

```dart
_dio.interceptors.add(QAInterceptor());
```

Now, all network requests and responses made by the Dio instance will be logged by the `QAInterceptor`.

## Viewing Logs

To view the logs, open `localhost:3000` on your device. 

If you want to view the logs on your laptop, ensure that your device and laptop are connected to the same WiFi network. Then, open the browser on your laptop and enter the IP address of the application running device (you can get ip from localhost:3000 also) followed by port `3000`.

For example, if the IP address of your device is `192.168.1.5`, you would enter `192.168.1.5:3000` in your browser.

This will allow you to monitor the network calls of your application in real-time.