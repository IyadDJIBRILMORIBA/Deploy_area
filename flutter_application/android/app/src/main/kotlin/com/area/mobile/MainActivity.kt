package com.area.mobile

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "area.deeplink/channel"
    private var deepLinkChannel: MethodChannel? = null
    private var initialLink: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        deepLinkChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        deepLinkChannel?.setMethodCallHandler { call, result ->
            if (call.method == "getInitialLink") {
                result.success(initialLink)
                initialLink = null // Clear après récupération
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        val action = intent?.action
        val data = intent?.data

        if (Intent.ACTION_VIEW == action && data != null) {
            val deepLink = data.toString()
            
            if (deepLinkChannel != null) {
                // Si Flutter est prêt, envoyer directement
                deepLinkChannel?.invokeMethod("onDeepLink", deepLink)
            } else {
                // Sinon, stocker pour récupération ultérieure
                initialLink = deepLink
            }
        }
    }
}

