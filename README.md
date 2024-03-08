# qa_logger

`qa_logger` is a Dart package that provides a simple and efficient way to monitor network calls and logs in your application. It's a good tool for QA and backend developers.

![qa_logger cover](https://raw.githubusercontent.com/athulacaj/publicFiles/main/qalogger/desktop.png)

<div style="display:flex;gap:14px">
<img src="https://raw.githubusercontent.com/athulacaj/publicFiles/main/qalogger/mob1.png" height="300px">
<img src="https://raw.githubusercontent.com/athulacaj/publicFiles/main/qalogger/mob2.png" height="300px">
</div>

## Features

- Easy integration with Dio
- Detailed logging of network requests and responses
- Helps in identifying network-related issues


## Installation

Add `qa_logger` to your `pubspec.yaml` file:

```yaml
dependencies:
  qa_logger: $currentVersion$
```

Then run `flutter pub get`.

## Usage

Import `qa_logger` in your Dart file:

```dart
import 'package:qa_logger/qa_logger.dart';
```

Add the `QAInterceptor` to your Dio instance:

```dart
if (Kproduction == false) {
  dio.interceptors.add(QaLogger().dioInterceptor);
}
```

Now, all network requests and responses made by the Dio instance will be logged by the `QAInterceptor`.
By default, the server will run on port 3000. If you want to change the port, you can add the following configuration in main.dart:
```dart
QaLogger.configure(port: 3001, wsPort: 8001);
```

## API for Getting Logs

The `qa_logs` package provides an API for getting logs by overriding the `debugPrint` function. This allows you to log messages using the `QaLogger` class, which will automatically log the messages to the `localhost:3000` server.

Here's how you can override the `debugPrint` function:

```dart
debugPrint = (message, {wrapWidth}) {
   if (Kproduction == true) return;
  QaLogger().log(message);
  if (message != null) {
    log(message, name: 'DebugPrint');
  }
};
```
### Handling Flutter Errors

In addition to logging debug messages, `qa_logs` can also be used to log Flutter errors. You can override the `FlutterError.onError` function to log error details using the `QaLogger` class:

```dart
FlutterError.onError = (FlutterErrorDetails details) {
   if (Kproduction == true) return;
  QaLogger().logError(details.toString());
};
```

With this setup, any calls to debugPrint in your application will be logged by the QaLogger and can be viewed on localhost:3000.

## Viewing Logs

To view the logs, open `localhost:3000` on your device. 

If you want to view the logs on your laptop, ensure that your device and laptop are connected to the same WiFi network. Then, open the browser on your laptop and enter the IP address of the application running device (you can get ip from localhost:3000 also) followed by port `3000`.

For example, if the IP address of your device is `192.168.1.5`, you would enter `192.168.1.5:3000` in your browser.

This will allow you to monitor the network calls of your application in real-time.

### Viewing logs from the Android Emulator on a PC browser

To view the logs from an Android emulator, you need to forward the necessary ports using the Android Debug Bridge (adb) tool. 

Run the following commands:

```bash
adb forward tcp:3000 tcp:3000
adb forward tcp:<ws_port> tcp:<ws_port>
```

note: Replace `<ws_port>` with the port number that is displayed in the localhost:3000 page.