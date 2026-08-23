package org.telon.flutter_gsm_sip_gateway

import android.app.*
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat

/**
 * HeadlessService - Foreground service for persistent background execution
 * 
 * This service runs in the foreground with a persistent notification,
 * executing headless tasks at regular intervals (2 seconds).
 * 
 * Key features:
 * - START_STICKY: Service restarts if killed by the system
 * - Foreground priority: Prevents OS from killing under memory pressure
 * - Periodic execution: Runs headless tasks every 2 seconds
 * - Notification: Shows persistent notification to satisfy Android requirements
 */
class HeadlessService : Service() {
    
    companion object {
        private const val TAG = "HeadlessService"
        
        // Notification configuration
        private const val SERVICE_NOTIFICATION_ID = 123456
        private const val CHANNEL_ID = "HEADLESS_SERVICE_CHANNEL"
        private const val CHANNEL_NAME = "Headless Service"
        
        // Execution interval in milliseconds
        private const val EXECUTION_INTERVAL_MS = 2000L
    }
    
    private val handler = Handler(Looper.getMainLooper())
    private var isRunning = false
    
    // Runnable for periodic execution
    private val recurringTask = object : Runnable {
        override fun run() {
            if (isRunning) {
                executeHeadlessTask()
                handler.postDelayed(this, EXECUTION_INTERVAL_MS)
            }
        }
    }
    
    override fun onCreate() {
        super.onCreate()
        Log.i(TAG, "HeadlessService created")
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.i(TAG, "HeadlessService started with startId: $startId")
        
        // Create notification channel for Android 8.0+
        createNotificationChannel()
        
        // Build and start foreground notification
        val notification = buildNotification()
        startForeground(SERVICE_NOTIFICATION_ID, notification)
        
        // Start periodic execution
        isRunning = true
        handler.post(recurringTask)
        
        // START_STICKY ensures service restarts if killed by the system
        return START_STICKY
    }
    
    override fun onDestroy() {
        Log.i(TAG, "HeadlessService destroyed")
        
        // Stop periodic execution
        isRunning = false
        handler.removeCallbacks(recurringTask)
        
        super.onDestroy()
    }
    
    override fun onBind(intent: Intent?): IBinder? {
        // This service is not bindable
        return null
    }
    
    /**
     * Create notification channel for Android 8.0+ (API 26+)
     */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Background service for headless JavaScript execution"
                setShowBadge(false)
                enableVibration(false)
                setSound(null, null)
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
            Log.i(TAG, "Notification channel created: $CHANNEL_ID")
        }
    }
    
    /**
     * Build the foreground service notification
     */
    private fun buildNotification(): Notification {
        // Create intent to bring app to foreground when notification is tapped
        val notificationIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra("from_notification", true)
        }
        
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            notificationIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        
        // Build notification
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Headless Service")
            .setContentText("Running background tasks...")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()
    }
    
    /**
     * Execute the headless task
     * This method is called every 2 seconds while the service is running
     */
    private fun executeHeadlessTask() {
        Log.d(TAG, "Executing headless task at ${System.currentTimeMillis()}")
        
        // Here you can add logic to:
        // 1. Check for pending events
        // 2. Process queued tasks
        // 3. Sync data with server
        // 4. Monitor system state
        
        // For integration with Flutter, you would typically:
        // - Use a FlutterEngineGroup to run headless Dart code
        // - Or use MethodChannel to communicate with main Flutter engine
        // - Or use WorkManager for scheduled background work
        
        // Example: Broadcast an event that Flutter can listen to
        val eventIntent = Intent("org.telon.flutter_gsm_sip_gateway.HEADLESS_EVENT").apply {
            putExtra("timestamp", System.currentTimeMillis())
            putExtra("event_type", "periodic_tick")
        }
        sendBroadcast(eventIntent)
    }
    
    companion object {
        /**
         * Check if the service is currently running
         */
        fun isServiceRunning(): Boolean {
            // This is a simplified check - in production you'd want to track
            // the service state more robustly
            return false // Will be implemented with proper state tracking
        }
    }
}
