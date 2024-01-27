package com.example.violence_detector

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate() {
        super.onCreate()
        MapKitFactory.setApiKey("7e4c995c-ba8a-42ee-880e-82b7c648e345")
      }
}
