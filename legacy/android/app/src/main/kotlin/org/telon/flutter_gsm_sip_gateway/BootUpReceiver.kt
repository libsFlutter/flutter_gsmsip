package org.telon.flutter_gsm_sip_gateway

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

/**
 * BootUpReceiver - Broadcast receiver for device boot completion
 * 
 * Automatically starts the HeadlessService when the device boots up,
 * ensuring continuous operation without manual intervention.
 * 
 * Listens for:
 * - ACTION_BOOT_COMPLETED: Standard boot completed broadcast
 * - ACTION_QUICKBOOT_POWERON: Quick boot broadcast (HTC, some manufacturers)
 * - ACTION_MY_PACKAGE_REPLACED: App update/replacement (optional)
 */
class BootUpReceiver : BroadcastReceiver() {
    
    companion object {
        private const val TAG = "BootUpReceiver"
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        Log.i(TAG, "Broadcast received: $action")
        
        when (action) {
            Intent.ACTION_BOOT_COMPLETED -> {
                Log.i(TAG, "Device boot completed - starting HeadlessService")
                startHeadlessService(context)
            }
            Intent.ACTION_MY_PACKAGE_REPLACED -> {
                Log.i(TAG, "Package replaced - restarting HeadlessService")
                startHeadlessService(context)
            }
            "android.intent.action.QUICKBOOT_POWERON" -> {
                Log.i(TAG, "Quick boot detected - starting HeadlessService")
                startHeadlessService(context)
            }
            else -> {
                Log.w(TAG, "Unknown broadcast action: $action")
            }
        }
    }
    
    /**
     * Start the HeadlessService as a foreground service
     */
    private fun startHeadlessService(context: Context) {
        try {
            // Check if service is already running (optional optimization)
            // This prevents multiple instances from being started
            
            val intent = Intent(context, HeadlessService::class.java)
            
            // Start as foreground service (required for Android 8.0+)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
            
            Log.i(TAG, "HeadlessService start request sent")
            
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start HeadlessService on boot", e)
        }
    }
}
