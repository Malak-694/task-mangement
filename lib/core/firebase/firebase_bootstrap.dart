import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Call [initialize] from [main] after [WidgetsFlutterBinding.ensureInitialized].
///
/// If native Firebase fails to connect (common on **Windows** desktop with the
/// Pigeon `channel-error`, or after a bad **hot restart**), [isReady] stays
/// false and the app can still use local SQLite auth.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _ready = false;

  static bool get isReady => _ready;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // ✅ Disable reCAPTCHA verification in debug mode
      // Prevents "RecaptchaAction network error" on emulators / no internet
      if (kDebugMode) {
        await FirebaseAuth.instance.setSettings(
          appVerificationDisabledForTesting: true,
        );
      }

      _ready = true;
    } catch (e) {
      _ready = false;
      debugPrint(
        'Firebase.initializeApp failed — cloud auth disabled; local DB auth still works.\n'
            'If you need Firebase: run on Android/iOS (or Chrome for web), run '
            '`flutter clean`, then rebuild (not hot-restart). Error: $e',
      );
    }
  }
}