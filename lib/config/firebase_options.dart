import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'env_config.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Firebase iOS SDK v11+ rejects ':web:' appIds on iOS/Android.
    // Use the native appId from env if present, otherwise derive it by
    // substituting the platform token in the web appId.
    final webAppId = EnvConfig.firebaseAppId;
    final String appId;
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      // Prefer explicit iOS appId; fall back to replacing ':web:' with ':ios:'
      appId = EnvConfig.firebaseIosAppId.isNotEmpty
          ? EnvConfig.firebaseIosAppId
          : webAppId.replaceFirst(':web:', ':ios:');
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      appId = EnvConfig.firebaseAndroidAppId.isNotEmpty
          ? EnvConfig.firebaseAndroidAppId
          : webAppId.replaceFirst(':web:', ':android:');
    } else {
      appId = webAppId;
    }

    return FirebaseOptions(
      apiKey: EnvConfig.firebaseApiKey,
      appId: appId,
      messagingSenderId: EnvConfig.firebaseMessagingSenderId,
      projectId: EnvConfig.firebaseProjectId,
      storageBucket: EnvConfig.firebaseStorageBucket,
    );
  }
}
