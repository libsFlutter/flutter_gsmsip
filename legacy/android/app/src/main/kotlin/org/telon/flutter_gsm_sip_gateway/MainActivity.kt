package org.telon.flutter_gsm_sip_gateway

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

/**
 * MainActivity - Main entry point for the Android application
 *
 * Registers native modules:
 * - ReplaceDialerModule: Default dialer management
 * - GatewayDialerModule: Gateway-specific dialer functionality
 */
class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register ReplaceDialerModule for default dialer management
        flutterEngine.plugins.add(ReplaceDialerModule())

        // Register GatewayDialerModule for gateway-specific dialer functionality
        flutterEngine.plugins.add(GatewayDialerModule())

        Log.d("MainActivity", "ReplaceDialerModule registered")
        Log.d("MainActivity", "GatewayDialerModule registered")
    }
}
