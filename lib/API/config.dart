import 'dart:io';

String get baseUrl {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:5001'; // Android emulator
  } else if (Platform.isIOS) {
    return 'http://localhost:5001'; // iOS simulator
  } else {
    return 'http://192.168.1.12:5001'; // Real devices access host
  }
}
