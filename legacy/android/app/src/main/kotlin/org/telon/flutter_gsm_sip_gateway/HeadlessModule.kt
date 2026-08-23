package org.telon.flutter_gsm_sip_gateway

import android.os.Bundle
import android.os.Handler
import android.os.HandlerThread
import android.content.Intent
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.embedding.engine.FlutterEngineGroup
import io.flutter.view.FlutterJNI

/**
 * HeadlessModule - Flutter method channel handler for headless service operations
 * 
 * Provides JavaScript API for:
 * - startService(): Start the headless background service
 * - stopService(): Stop the headless background service
 * - toForeground(): Bring the app to foreground
 * - toBackground(): Send app to background (currently no-op)
 */
class HeadlessModule : MethodCallHandler {
    
    companion object {
        private const val TAG = "HeadlessModule"
        private const val CHANNEL_NAME = "gsm_sip_gateway/headless"
        
        // Handler thread for background operations
        @Volatile
        private var handlerThread: HandlerThread? = null
        
        @Volatile
        private var handler: Handler? = null
        
        /**
         * Initialize the handler thread with foreground priority
         * This prevents the OS from killing the thread under memory pressure
         */
        fun initializeHandler() {
            if (handlerThread == null) {
                handlerThread = HandlerThread("HeadlessModuleThread", android.os.Process.THREAD_PRIORITY_FOREGROUND)
                handlerThread?.start()
                handler = Handler(handlerThread!!.looper)
                Log.i(TAG, "Handler thread initialized with FOREGROUND priority")
            }
        }
        
        /**
         * Get the shared handler instance
         */
        fun getHandler(): Handler? {
            return handler
        }
    }
    
    private var methodChannel: MethodChannel? = null
    
    /**
     * Register this module with the Flutter engine
     */
    fun registerWith(flutterEngine: FlutterEngine) {
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        methodChannel?.setMethodCallHandler(this)
        Log.i(TAG, "HeadlessModule registered with channel: $CHANNEL_NAME")
    }
    
    /**
     * Handle method calls from Flutter/Dart
     */
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startService" -> startService(result)
            "stopService" -> stopService(result)
            "toForeground" -> toForeground(result)
            "toBackground" -> toBackground(result)
            else -> result.notImplemented()
        }
    }
    
    /**
     * Start the HeadlessService foreground service
     */
    private fun startService(result: MethodChannel.Result) {
        Log.i(TAG, "startService called")
        
        try {
            // Ensure handler is initialized
            initializeHandler()
            
            // Get application context
            val context = flutterEngine?.applicationContext
                ?: return result.error("NO_CONTEXT", "Flutter engine context not available", null)
            
            // Start the headless service
            val intent = Intent(context, HeadlessService::class.java)
            context.startForegroundService(intent)
            
            Log.i(TAG, "HeadlessService started successfully")
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start HeadlessService", e)
            result.error("START_SERVICE_FAILED", e.message, null)
        }
    }
    
    /**
     * Stop the HeadlessService foreground service
     */
    private fun stopService(result: MethodChannel.Result) {
        Log.i(TAG, "stopService called")
        
        try {
            val context = flutterEngine?.applicationContext
                ?: return result.error("NO_CONTEXT", "Flutter engine context not available", null)
            
            val intent = Intent(context, HeadlessService::class.java)
            context.stopService(intent)
            
            Log.i(TAG, "HeadlessService stopped successfully")
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to stop HeadlessService", e)
            result.error("STOP_SERVICE_FAILED", e.message, null)
        }
    }
    
    /**
     * Bring the app to foreground by launching MainActivity
     */
    private fun toForeground(result: MethodChannel.Result) {
        Log.i(TAG, "toForeground called")
        
        try {
            val context = flutterEngine?.applicationContext
                ?: return result.error("NO_CONTEXT", "Flutter engine context not available", null)
            
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
                putExtra("foreground", true)
            }
            
            context.startActivity(intent)
            Log.i(TAG, "App brought to foreground")
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to bring app to foreground", e)
            result.error("TO_FOREGROUND_FAILED", e.message, null)
        }
    }
    
    /**
     * Send app to background (currently no-op on Android)
     */
    private fun toBackground(result: MethodChannel.Result) {
        Log.i(TAG, "toBackground called (no-op)")
        
        // Android doesn't provide a direct way to send app to background
        // This is intentionally a no-op
        result.success(null)
    }
    
    /**
     * Clean up resources
     */
    fun dispose() {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        Log.i(TAG, "HeadlessModule disposed")
    }
}
