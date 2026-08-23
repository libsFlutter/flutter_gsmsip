package org.telon.flutter_gsm_sip_gateway

import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.view.FlutterCallbackInformation
import io.flutter.view.FlutterMain
import java.util.concurrent.atomic.AtomicBoolean

/**
 * HeadlessEventService - Service for executing headless Flutter/Dart tasks
 * 
 * This service runs Flutter engine in headless mode to execute Dart code
 * when the app is not visible or device is in sleep mode.
 * 
 * Key features:
 * - Headless Flutter engine execution
 * - Task timeout handling (5 seconds)
 * - Wake lock acquisition during task execution
 * - Data passing from native to Dart
 * 
 * Note: This is a simplified implementation. For production use with Flutter,
 * consider using flutter_workmanager or android_alarm_manager_plus packages
 * which provide more robust headless execution handling.
 */
class HeadlessEventService {
    
    companion object {
        private const val TAG = "HeadlessEventService"
        
        // Task configuration
        private const val TASK_TIMEOUT_MS = 5000L
        private const val HEADLESS_CALLBACK_HANDLE = "headlessCallbackHandle"
        
        // Shared headless engine (singleton pattern)
        @Volatile
        private var headlessEngine: FlutterEngine? = null
        
        @Volatile
        private var isTaskRunning = AtomicBoolean(false)
        
        /**
         * Initialize the headless Flutter engine
         * Must be called with a valid callback handle from Dart
         */
        fun initializeHeadlessEngine(context: android.content.Context, callbackHandle: Long) {
            if (headlessEngine != null) {
                Log.w(TAG, "Headless engine already initialized")
                return
            }
            
            synchronized(this) {
                if (headlessEngine == null) {
                    Log.i(TAG, "Initializing headless Flutter engine")
                    headlessEngine = FlutterEngine(context)
                    
                    // Get the callback information
                    val callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(callbackHandle)
                    
                    if (callbackInfo != null) {
                        val dartBundle = FlutterMain.findAppBundlePath()
                        headlessEngine?.dartExecutor?.executeDartCallback(
                            DartExecutor.DartCallback(
                                context.assets,
                                dartBundle,
                                callbackInfo
                            )
                        )
                        Log.i(TAG, "Headless engine started with callback: ${callbackInfo.callbackName}")
                    } else {
                        Log.e(TAG, "Callback information not found for handle: $callbackHandle")
                    }
                }
            }
        }
        
        /**
         * Execute a headless task with data
         * 
         * @param context Android context
         * @param taskName Name of the task to execute
         * @param data Data to pass to the task
         * @param callback Callback to invoke when task completes
         */
        fun executeTask(
            context: android.content.Context,
            taskName: String,
            data: Bundle?,
            callback: ((Boolean, Any?) -> Unit)? = null
        ) {
            // Prevent concurrent task execution
            if (!isTaskRunning.compareAndSet(false, true)) {
                Log.w(TAG, "Task already running, skipping execution")
                callback?.invoke(false, "Task already running")
                return
            }
            
            Log.i(TAG, "Executing headless task: $taskName")
            
            try {
                // Acquire wake lock to prevent CPU sleep
                val wakeLock = acquireWakeLock(context)
                
                // Create task intent data
                val taskData = Bundle()
                taskData.putString("task_name", taskName)
                if (data != null) {
                    taskData.putAll(data)
                }
                
                // Execute task with timeout
                val handler = android.os.Handler(android.os.Looper.getMainLooper())
                var taskCompleted = false
                
                // Set up timeout
                val timeoutRunnable = Runnable {
                    if (!taskCompleted) {
                        Log.e(TAG, "Task timed out after ${TASK_TIMEOUT_MS}ms: $taskName")
                        isTaskRunning.set(false)
                        wakeLock?.release()
                        callback?.invoke(false, "Task timeout")
                    }
                }
                handler.postDelayed(timeoutRunnable, TASK_TIMEOUT_MS)
                
                // Execute the task via MethodChannel to headless engine
                // Note: This requires the headless engine to have a registered MethodChannel
                val engine = headlessEngine
                if (engine != null) {
                    val channel = io.flutter.plugin.common.MethodChannel(
                        engine.dartExecutor.binaryMessenger,
                        "gsm_sip_gateway/headless_task"
                    )
                    
                    channel.invokeMethod(
                        "executeTask",
                        taskData,
                        object : io.flutter.plugin.common.MethodChannel.Result {
                            override fun success(result: Any?) {
                                taskCompleted = true
                                handler.removeCallbacks(timeoutRunnable)
                                isTaskRunning.set(false)
                                wakeLock?.release()
                                Log.i(TAG, "Task completed successfully: $taskName")
                                callback?.invoke(true, result)
                            }
                            
                            override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
                                taskCompleted = true
                                handler.removeCallbacks(timeoutRunnable)
                                isTaskRunning.set(false)
                                wakeLock?.release()
                                Log.e(TAG, "Task failed: $taskName - $errorMessage")
                                callback?.invoke(false, errorMessage)
                            }
                            
                            override fun notImplemented() {
                                taskCompleted = true
                                handler.removeCallbacks(timeoutRunnable)
                                isTaskRunning.set(false)
                                wakeLock?.release()
                                Log.w(TAG, "Task not implemented in Dart: $taskName")
                                callback?.invoke(false, "Not implemented")
                            }
                        }
                    )
                } else {
                    // No headless engine - execute directly
                    Log.w(TAG, "No headless engine available, executing task directly")
                    executeTaskDirectly(context, taskName, data)
                    taskCompleted = true
                    isTaskRunning.set(false)
                    wakeLock?.release()
                    callback?.invoke(true, null)
                }
                
            } catch (e: Exception) {
                Log.e(TAG, "Error executing headless task", e)
                isTaskRunning.set(false)
                callback?.invoke(false, e.message)
            }
        }
        
        /**
         * Execute task directly without Flutter engine
         * Fallback method when headless engine is not available
         */
        private fun executeTaskDirectly(
            context: android.content.Context,
            taskName: String,
            data: Bundle?
        ) {
            Log.i(TAG, "Executing task directly: $taskName")
            
            // Broadcast event for any listeners
            val eventIntent = Intent("org.telon.flutter_gsm_sip_gateway.HEADLESS_EVENT").apply {
                putExtra("task_name", taskName)
                putExtra("timestamp", System.currentTimeMillis())
                if (data != null) {
                    putExtras(data)
                }
            }
            context.sendBroadcast(eventIntent)
        }
        
        /**
         * Acquire a partial wake lock to prevent CPU sleep
         */
        private fun acquireWakeLock(context: android.content.Context): android.os.PowerManager.WakeLock? {
            try {
                val powerManager = context.getSystemService(android.content.Context.POWER_SERVICE) as android.os.PowerManager
                val wakeLock = powerManager.newWakeLock(
                    android.os.PowerManager.PARTIAL_WAKE_LOCK,
                    "HeadlessEventService::WakeLock"
                )
                wakeLock.acquire(5 * 60 * 1000L) // 5 minutes max
                Log.d(TAG, "Wake lock acquired")
                return wakeLock
            } catch (e: Exception) {
                Log.e(TAG, "Failed to acquire wake lock", e)
                return null
            }
        }
        
        /**
         * Shutdown the headless engine
         */
        fun shutdown() {
            synchronized(this) {
                headlessEngine?.destroy()
                headlessEngine = null
                Log.i(TAG, "Headless engine shutdown")
            }
        }
        
        /**
         * Check if headless engine is initialized
         */
        fun isEngineInitialized(): Boolean {
            return headlessEngine != null
        }
    }
}
