import 'package:flutter_express/flutter_express.dart';

void main() {
  // QaLogger().log('Hello World');
  FlutterExpress app = FlutterExpress();

  app.get('/', (req, res) {});

  app.listen(3000, () {
    print('Server is running on port 3000');
  });
}
