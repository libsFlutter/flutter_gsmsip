package org.telon.flutter_gsm_sip_gateway

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Build
import android.telecom.TelecomManager
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * ReplaceDialerModule - Native Android module for default dialer management
 * 
 * This module provides functionality to:
 * - Check if the app is the default dialer
 * - Request to become the default dialer
 * - Check if the app can become the default dialer
 * 
 * Implements ActivityEventListener interface (GAP-013) to properly handle
 * activity results, fixing the callback timing issue (GAP-010).
 * 
 * @author GOSTsimbox Team
 * @since 2026-03-06
 */
class ReplaceDialerModule : FlutterPlugin, MethodCallHandler, ActivityAware {
    
    companion object {
        private const val TAG = "ReplaceDialerModule"
        private const val CHANNEL = "org.telon/replace_dialer"
        private const val RC_DEFAULT_PHONE = 3289
    }
    
    // Context references
    private var applicationContext: Context? = null
    private var activity: Activity? = null
    
    // Method channel
    private var channel: MethodChannel? = null
    
    // Callback storage for setDefaultDialer (GAP-010 fix)
    // Stored as instance field with synchronization (GAP-004)
    private var setDefaultCallback: Result? = null
    private val callbackLock = Any()
    
    // FlutterPlugin lifecycle
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onAttachedToEngine()")
        applicationContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel?.setMethodCallHandler(this)
    }
    
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onDetachedFromEngine()")
        channel?.setMethodCallHandler(null)
        channel = null
        applicationContext = null
    }
    
    // ActivityAware lifecycle
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.d(TAG, "onAttachedToActivity()")
        activity = binding.activity
        // Register activity result listener (GAP-013)
        binding.addActivityResultListener(this::onActivityResult)
    }
    
    override fun onDetachedFromActivityForConfigChanges() {
        Log.d(TAG, "onDetachedFromActivityForConfigChanges()")
        activity = null
    }
    
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Log.d(TAG, "onReattachedToActivityForConfigChanges()")
        activity = binding.activity
        binding.addActivityResultListener(this::onActivityResult)
    }
    
    override fun onDetachedFromActivity() {
        Log.d(TAG, "onDetachedFromActivity()")
        activity = null
    }
    
    // MethodCallHandler implementation
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "isDefaultDialer" -> isDefaultDialer(result)
            "setDefaultDialer" -> setDefaultDialer(result)
            "canSetDefaultDialer" -> canSetDefaultDialer(result)
            else -> result.notImplemented()
        }
    }
    
    /**
     * Check if this app is the default dialer
     * 
     * @param result MethodChannel result callback
     */
    private fun isDefaultDialer(result: Result) {
        Log.d(TAG, "isDefaultDialer() called")
        
        try {
            // Pre-M Android: return true (dialer concept not applicable)
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
                Log.d(TAG, "Android version < M (API 23), returning true")
                result.success(true)
                return
            }
            
            val telecomManager = applicationContext?.getSystemService(Context.TELECOM_SERVICE) as? TelecomManager
                ?: throw IllegalStateException("TelecomManager not available")
            
            val isDefault = telecomManager.defaultDialerPackage == applicationContext?.packageName
            Log.d(TAG, "isDefaultDialer: $isDefault (current package: ${applicationContext?.packageName})")
            
            result.success(isDefault)
        } catch (e: Exception) {
            Log.e(TAG, "Error checking if default dialer", e)
            result.error("IS_DEFAULT_DIALER_ERROR", "Failed to check if default dialer: ${e.message}", e)
        }
    }
    
    /**
     * Request to become the default dialer
     * 
     * GAP-010 FIX: Callback is NOT invoked immediately.
     * Instead, it's stored and invoked in onActivityResult() after user confirmation.
     * 
     * @param result MethodChannel result callback
     */
    private fun setDefaultDialer(result: Result) {
        Log.d(TAG, "setDefaultDialer() called")
        
        try {
            // Pre-M Android: No dialer concept, return success immediately
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
                Log.d(TAG, "Android version < M (API 23), returning success immediately")
                result.success(true)
                return
            }
            
            // Store callback in instance field with synchronization (GAP-004)
            synchronized(callbackLock) {
                if (setDefaultCallback != null) {
                    // Another call in progress, reject new one
                    Log.w(TAG, "setDefaultDialer already in progress, rejecting new request")
                    result.error("CALL_IN_PROGRESS", "Another setDefaultDialer call is in progress", null)
                    return
                }
                setDefaultCallback = result
            }
            
            // Create intent to request default dialer status
            val intent = Intent(TelecomManager.ACTION_CHANGE_DEFAULT_DIALER).apply {
                putExtra(TelecomManager.EXTRA_CHANGE_DEFAULT_DIALER_PACKAGE_NAME, applicationContext?.packageName)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            
            // Start activity for result
            // GAP-010: Callback will be invoked in onActivityResult(), NOT here
            activity?.startActivityForResult(intent, RC_DEFAULT_PHONE)
                ?: throw IllegalStateException("Activity not available")
            
            Log.d(TAG, "setDefaultDialer: Started activity, waiting for user confirmation")
            // Note: result will be delivered via onActivityResult()
            
        } catch (e: Exception) {
            Log.e(TAG, "Error setting default dialer", e)
            // Clear callback on error
            synchronized(callbackLock) {
                setDefaultCallback = null
            }
            result.error("SET_DEFAULT_DIALER_ERROR", "Failed to set default dialer: ${e.message}", e)
        }
    }
    
    /**
     * Check if this app can be set as default dialer
     * 
     * @param result MethodChannel result callback
     */
    private fun canSetDefaultDialer(result: Result) {
        Log.d(TAG, "canSetDefaultDialer() called")
        
        try {
            // Pre-M Android: return false (dialer concept not applicable)
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
                Log.d(TAG, "Android version < M (API 23), returning false")
                result.success(false)
                return
            }
            
            val telecomManager = applicationContext?.getSystemService(Context.TELECOM_SERVICE) as? TelecomManager
                ?: throw IllegalStateException("TelecomManager not available")
            
            // Can set if not already default
            val canSet = telecomManager.defaultDialerPackage != applicationContext?.packageName
            Log.d(TAG, "canSetDefaultDialer: $canSet (current default: ${telecomManager.defaultDialerPackage})")
            
            result.success(canSet)
        } catch (e: Exception) {
            Log.e(TAG, "Error checking if can set default dialer", e)
            result.error("CAN_SET_DEFAULT_DIALER_ERROR", "Failed to check if can set default dialer: ${e.message}", e)
        }
    }
    
    /**
     * Handle activity result for setDefaultDialer request
     * 
     * GAP-010 FIX: This is where the callback is actually invoked,
     * after the user has confirmed or cancelled the system dialog.
     * 
     * GAP-013: Implements ActivityEventListener interface functionality
     * 
     * @param requestCode Request code (RC_DEFAULT_PHONE)
     * @param resultCode Result code (RESULT_OK or RESULT_CANCELED)
     * @param data Intent data (not used)
     * @return true if handled, false otherwise
     */
    private fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        Log.d(TAG, "onActivityResult() called: requestCode=$requestCode, resultCode=$resultCode")
        
        if (requestCode == RC_DEFAULT_PHONE) {
            val callback: Result?
            synchronized(callbackLock) {
                callback = setDefaultCallback
                setDefaultCallback = null
            }
            
            if (callback == null) {
                Log.w(TAG, "onActivityResult: No callback stored, ignoring result")
                return true
            }
            
            // Invoke callback based on user's decision
            if (resultCode == Activity.RESULT_OK) {
                Log.w(TAG, "setDefaultDialer: User confirmed, RESULT_OK")
                callback.success(true)
            } else {
                Log.w(TAG, "setDefaultDialer: User cancelled, resultCode=$resultCode")
                callback.success(false)
            }
            
            return true
        }
        
        return false
    }
}
