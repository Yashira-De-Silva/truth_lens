import 'dart:io';

String get kBaseUrl => Platform.isAndroid ? 'http://10.0.2.2:8000/api' : 'http://127.0.0.1:8000/api';
String get kMlServiceUrl => Platform.isAndroid ? 'http://10.0.2.2:5001' : 'http://127.0.0.1:5001';
