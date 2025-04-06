import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCoXfE_p4x7NHAn-0u1AwhfyCaTr5WmScQ',
    appId: '1:841661660446:android:2d21d913e78bca45c8dd0f',
    messagingSenderId: '841661660446',
    projectId: 'yemen-aqar-app-c9932',
    storageBucket: 'yemen-aqar-app-c9932.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA0w2uK2pJ3K3HOlCXDfobH8kJCLURGFfA',
    appId: '1:841661660446:ios:753cf39914dd8ac9c8dd0f',
    messagingSenderId: '841661660446',
    projectId: 'yemen-aqar-app-c9932',
    storageBucket: 'yemen-aqar-app-c9932.firebasestorage.app',
    iosBundleId: 'com.nanoteam.yemenaqar',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDQBHpJ8TOpzs-tL6BBPnmEr9PHYoxtHNI',
    appId: '1:841661660446:web:5274dd5aed18b749c8dd0f',
    messagingSenderId: '841661660446',
    projectId: 'yemen-aqar-app-c9932',
    authDomain: 'yemen-aqar-app-c9932.firebaseapp.com',
    storageBucket: 'yemen-aqar-app-c9932.firebasestorage.app',
    measurementId: 'G-B54D8SGF4R',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA0w2uK2pJ3K3HOlCXDfobH8kJCLURGFfA',
    appId: '1:841661660446:ios:1e4da59af3308bdbc8dd0f',
    messagingSenderId: '841661660446',
    projectId: 'yemen-aqar-app-c9932',
    storageBucket: 'yemen-aqar-app-c9932.firebasestorage.app',
    iosBundleId: 'com.yemen.aqar',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDQBHpJ8TOpzs-tL6BBPnmEr9PHYoxtHNI',
    appId: '1:841661660446:web:27695241bf398df2c8dd0f',
    messagingSenderId: '841661660446',
    projectId: 'yemen-aqar-app-c9932',
    authDomain: 'yemen-aqar-app-c9932.firebaseapp.com',
    storageBucket: 'yemen-aqar-app-c9932.firebasestorage.app',
    measurementId: 'G-KJT8VC1VRE',
  );

}