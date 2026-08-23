package org.telon.flutter_gsm_sip_gateway

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.telecom.TelecomManager
import android.telephony.TelephonyManager
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * GatewayDialerModule - Native Android module for GOSTsimbox Gateway dialer
 *
 * This module provides gateway-specific dialer functionality:
 * - Gateway status (SIP registration, GSM signal)
 * - Available lines (SIP, GSM-1, GSM-2)
 * - Call route selection with cost estimates
 * - Network quality stats (latency, jitter, MOS)
 * - Bridge call status (SIP leg + GSM leg)
 * - Audio levels monitoring
 * - Bridge call initiation
 *
 * @author GOSTsimbox Team
 * @since 2026-03-11
 */
class GatewayDialerModule : FlutterPlugin, MethodCallHandler, ActivityAware {

    companion object {
        private const val TAG = "GatewayDialerModule"
        private const val CHANNEL = "gsm_sip_gateway/dialer"

        // Request codes
        private const val RC_BRIDGE_CALL = 3290
    }

    // Context references
    private var applicationContext: Context? = null
    private var activity: Activity? = null

    // Method channel
    private var channel: MethodChannel? = null

    // TelephonyManager
    private var telephonyManager: TelephonyManager? = null

    // Callback storage for bridge call
    private var bridgeCallCallback: Result? = null
    private val callbackLock = Any()

    // FlutterPlugin lifecycle
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onAttachedToEngine()")
        applicationContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel?.setMethodCallHandler(this)
        telephonyManager = applicationContext?.getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onDetachedFromEngine()")
        channel?.setMethodCallHandler(null)
        channel = null
        applicationContext = null
        telephonyManager = null
    }

    // ActivityAware lifecycle
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.d(TAG, "onAttachedToActivity()")
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Log.d(TAG, "onDetachedFromActivityForConfigChanges()")
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Log.d(TAG, "onReattachedToActivityForConfigChanges()")
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        Log.d(TAG, "onDetachedFromActivity()")
        activity = null
    }

    // MethodCallHandler implementation
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            // Core dialer methods
            "getRecentCalls" -> getRecentCalls(call, result)
            "initiateSipCall" -> initiateSipCall(call, result)
            "initiateGsmCall" -> initiateGsmCall(call, result)
            "openSystemDialer" -> openSystemDialer(call, result)

            // Gateway-specific methods
            "getAvailableLines" -> getAvailableLines(result)
            "getGatewayStatus" -> getGatewayStatus(result)
            "getAvailableRoutes" -> getAvailableRoutes(call, result)
            "selectRoute" -> selectRoute(call, result)
            "getCurrentRoute" -> getCurrentRoute(result)
            "getNetworkQualityStats" -> getNetworkQualityStats(result)
            "getBridgeCallStatus" -> getBridgeCallStatus(call, result)
            "getAudioLevels" -> getAudioLevels(result)
            "initiateBridgeCall" -> initiateBridgeCall(call, result)

            else -> result.notImplemented()
        }
    }

    // ========================================================================
    // Core Dialer Methods
    // ========================================================================

    private fun getRecentCalls(call: MethodCall, result: Result) {
        Log.d(TAG, "getRecentCalls() called")

        try {
            val limit = call.argument<Int>("limit") ?: 50

            // Query call log
            val calls = mutableListOf<Map<String, Any>>()

            // Note: Requires READ_CALL_LOG permission
            val cursor = applicationContext?.contentResolver?.query(
                android.provider.CallLog.Calls.CONTENT_URI,
                null,
                null,
                null,
                "${android.provider.CallLog.Calls.DATE} DESC LIMIT $limit"
            )

            cursor?.use {
                val numberIndex = it.getColumnIndex(android.provider.CallLog.Calls.NUMBER)
                val nameIndex = it.getColumnIndex(android.provider.CallLog.Calls.CACHED_NAME)
                val dateIndex = it.getColumnIndex(android.provider.CallLog.Calls.DATE)
                val durationIndex = it.getColumnIndex(android.provider.CallLog.Calls.DURATION)
                val typeIndex = it.getColumnIndex(android.provider.CallLog.Calls.TYPE)

                while (it.moveToNext()) {
                    val number = it.getString(numberIndex) ?: ""
                    val name = nameIndex.takeIf { i -> i >= 0 }?.let { i -> it.getString(i) }
                    val date = it.getLong(dateIndex)
                    val duration = it.getInt(durationIndex)
                    val type = it.getInt(typeIndex)

                    calls.add(mapOf(
                        "id" to "$date",
                        "phoneNumber" to number,
                        "contactName" to (name ?: ""),
                        "timestamp" to java.time.Instant.ofEpochMilli(date).toString(),
                        "duration" to duration,
                        "isIncoming" to (type == android.provider.CallLog.Calls.INCOMING_TYPE),
                        "wasMissed" to (type == android.provider.CallLog.Calls.MISSED_TYPE)
                    ))
                }
            }

            Log.d(TAG, "getRecentCalls: Retrieved ${calls.size} calls")
            result.success(calls)

        } catch (e: Exception) {
            Log.e(TAG, "Error getting recent calls", e)
            result.error("GET_RECENT_CALLS_ERROR", "Failed to get recent calls: ${e.message}", e)
        }
    }

    private fun initiateSipCall(call: MethodCall, result: Result) {
        Log.d(TAG, "initiateSipCall() called: ${call.argument<String>("phoneNumber")}")

        try {
            val phoneNumber = call.argument<String>("phoneNumber") ?: ""

            // SIP call initiation - delegate to SIP service
            // This would integrate with PJSIP library
            Log.d(TAG, "initiateSipCall: SIP call to $phoneNumber (not implemented)")

            // For now, open system dialer as fallback
            val intent = Intent(Intent.ACTION_CALL).apply {
                data = Uri.parse("tel:$phoneNumber")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            applicationContext?.startActivity(intent)

            result.success(true)

        } catch (e: Exception) {
            Log.e(TAG, "Error initiating SIP call", e)
            result.error("INITIATE_SIP_CALL_ERROR", "Failed to initiate SIP call: ${e.message}", e)
        }
    }

    private fun initiateGsmCall(call: MethodCall, result: Result) {
        Log.d(TAG, "initiateGsmCall() called: ${call.argument<String>("phoneNumber")}")

        try {
            val phoneNumber = call.argument<String>("phoneNumber") ?: ""

            // GSM call via system dialer
            val intent = Intent(Intent.ACTION_CALL).apply {
                data = Uri.parse("tel:$phoneNumber")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            applicationContext?.startActivity(intent)

            Log.d(TAG, "initiateGsmCall: GSM call initiated to $phoneNumber")
            result.success(true)

        } catch (e: Exception) {
            Log.e(TAG, "Error initiating GSM call", e)
            result.error("INITIATE_GSM_CALL_ERROR", "Failed to initiate GSM call: ${e.message}", e)
        }
    }

    private fun openSystemDialer(call: MethodCall, result: Result) {
        Log.d(TAG, "openSystemDialer() called")

        try {
            val phoneNumber = call.argument<String>("phoneNumber")

            val intent = Intent(Intent.ACTION_DIAL).apply {
                if (phoneNumber != null) {
                    data = Uri.parse("tel:$phoneNumber")
                }
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            applicationContext?.startActivity(intent)

            Log.d(TAG, "openSystemDialer: System dialer opened")
            result.success(true)

        } catch (e: Exception) {
            Log.e(TAG, "Error opening system dialer", e)
            result.error("OPEN_SYSTEM_DIALER_ERROR", "Failed to open system dialer: ${e.message}", e)
        }
    }

    // ========================================================================
    // Gateway-Specific Methods
    // ========================================================================

    /**
     * Get available gateway lines (SIP, GSM-1, GSM-2)
     */
    private fun getAvailableLines(result: Result) {
        Log.d(TAG, "getAvailableLines() called")

        try {
            val lines = mutableListOf<Map<String, Any>>()

            // SIP Line
            val sipStatus = getSipRegistrationStatus()
            lines.add(mapOf(
                "id" to "sip",
                "name" to "SIP Line",
                "status" to if (sipStatus) 0 else 2, // 0=available, 2=unavailable
                "signalStrength" to "",
                "networkType" to "SIP",
                "isRegistered" to sipStatus
            ))

            // GSM Line 1 (SIM-1)
            val gsm1Signal = getGsmSignalStrength(0)
            val gsm1Network = getGsmNetworkType(0)
            lines.add(mapOf(
                "id" to "gsm-1",
                "name" to "GSM (SIM-1)",
                "status" to if (gsm1Signal > 0) 0 else 2,
                "signalStrength" to "$gsm1Signal%",
                "networkType" to gsm1Network,
                "isRegistered" to (gsm1Signal > 0)
            ))

            // GSM Line 2 (SIM-2) - if dual SIM
            if (isDualSim()) {
                val gsm2Signal = getGsmSignalStrength(1)
                val gsm2Network = getGsmNetworkType(1)
                lines.add(mapOf(
                    "id" to "gsm-2",
                    "name" to "GSM (SIM-2)",
                    "status" to if (gsm2Signal > 0) 0 else 2,
                    "signalStrength" to "$gsm2Signal%",
                    "networkType" to gsm2Network,
                    "isRegistered" to (gsm2Signal > 0)
                ))
            }

            Log.d(TAG, "getAvailableLines: Retrieved ${lines.size} lines")
            result.success(lines)

        } catch (e: Exception) {
            Log.e(TAG, "Error getting available lines", e)
            result.error("GET_AVAILABLE_LINES_ERROR", "Failed to get available lines: ${e.message}", e)
        }
    }

    /**
     * Get gateway status (SIP registration, GSM signal)
     */
    private fun getGatewayStatus(result: Result) {
        Log.d(TAG, "getGatewayStatus() called")

        try {
            val sipRegistered = getSipRegistrationStatus()
            val gsmSignal = getGsmSignalStrength(0)
            val gsmNetwork = getGsmNetworkType(0)

            val status = mapOf(
                "sipRegistered" to sipRegistered,
                "gsmSignalStrength" to gsmSignal,
                "gsmNetworkType" to gsmNetwork
            )

            Log.d(TAG, "getGatewayStatus: SIP=$sipRegistered, GSM=$gsmSignal% ($gsmNetwork)")
            result.success(status)

        } catch (e: Exception) {
            Log.e(TAG, "Error getting gateway status", e)
            result.error("GET_GATEWAY_STATUS_ERROR", "Failed to get gateway status: ${e.message}", e)
        }
    }

    /**
     * Get available call routes for a phone number
     */
    private fun getAvailableRoutes(call: MethodCall, result: Result) {
        Log.d(TAG, "getAvailableRoutes() called: ${call.argument<String>("phoneNumber")}")

        try {
            val phoneNumber = call.argument<String>("phoneNumber") ?: ""
            val routes = mutableListOf<Map<String, Any>>()

            // SIP Bridge Route (SIP → Gateway → GSM)
            val sipStatus = getSipRegistrationStatus()
            if (sipStatus) {
                routes.add(mapOf(
                    "route" to 0, // sipBridge
                    "displayName" to "SIP Bridge",
                    "costPerMinute" to 0.0,
                    "currency" to "RUB",
                    "qualityRating" to "★★★★★",
                    "lineInfo" to mapOf(
                        "id" to "sip",
                        "name" to "SIP Line",
                        "status" to 0,
                        "signalStrength" to "",
                        "networkType" to "SIP",
                        "isRegistered" to true
                    )
                ))
            }

            // Direct GSM Route (SIM-1)
            val gsm1Signal = getGsmSignalStrength(0)
            if (gsm1Signal > 0) {
                routes.add(mapOf(
                    "route" to 1, // directGsm
                    "displayName" to "GSM (SIM-1)",
                    "costPerMinute" to 5.0, // Example tariff
                    "currency" to "RUB",
                    "qualityRating" to "★★★★☆",
                    "lineInfo" to mapOf(
                        "id" to "gsm-1",
                        "name" to "GSM (SIM-1)",
                        "status" to 0,
                        "signalStrength" to "$gsm1Signal%",
                        "networkType" to getGsmNetworkType(0),
                        "isRegistered" to true
                    )
                ))
            }

            // Direct GSM Route (SIM-2) - if dual SIM
            if (isDualSim()) {
                val gsm2Signal = getGsmSignalStrength(1)
                if (gsm2Signal > 0) {
                    routes.add(mapOf(
                        "route" to 1, // directGsm
                        "displayName" to "GSM (SIM-2)",
                        "costPerMinute" to 3.0, // Example tariff
                        "currency" to "RUB",
                        "qualityRating" to "★★★☆☆",
                        "lineInfo" to mapOf(
                            "id" to "gsm-2",
                            "name" to "GSM (SIM-2)",
                            "status" to 0,
                            "signalStrength" to "$gsm2Signal%",
                            "networkType" to getGsmNetworkType(1),
                            "isRegistered" to true
                        )
                    ))
                }
            }

            Log.d(TAG, "getAvailableRoutes: Retrieved ${routes.size} routes")
            result.success(routes)

        } catch (e: Exception) {
            Log.e(TAG, "Error getting available routes", e)
            result.error("GET_AVAILABLE_ROUTES_ERROR", "Failed to get available routes: ${e.message}", e)
        }
    }

    /**
     * Select call route
     */
    private fun selectRoute(call: MethodCall, result: Result) {
        Log.d(TAG, "selectRoute() called: route=${call.argument<Int>("route")}")

        try {
            val route = call.argument<Int>("route") ?: 0

            // Store selected route in preferences
            val prefs = applicationContext?.getSharedPreferences("gateway_prefs", Context.MODE_PRIVATE)
            prefs?.edit()?.putInt("selected_route", route)?.apply()

            Log.d(TAG, "selectRoute: Route $route selected")
            result.success(true)

        } catch (e: Exception) {
            Log.e(TAG, "Error selecting route", e)
            result.error("SELECT_ROUTE_ERROR", "Failed to select route: ${e.message}", e)
        }
    }

    /**
     * Get current call route
     */
    private fun getCurrentRoute(result: Result) {
        Log.d(TAG, "getCurrentRoute() called")

        try {
            val prefs = applicationContext?.getSharedPreferences("gateway_prefs", Context.MODE_PRIVATE)
            val route = prefs?.getInt("selected_route", 0) ?: 0

            Log.d(TAG, "getCurrentRoute: Current route=$route")
            result.success(route)

        } catch (e: Exception) {
            Log.e(TAG, "Error getting current route", e)
            result.error("GET_CURRENT_ROUTE_ERROR", "Failed to get current route: ${e.message}", e)
        }
    }

    /**
     * Get network quality stats for active call
     */
    private fun getNetworkQualityStats(result: Result) {
        Log.d(TAG, "getNetworkQualityStats() called")

        try {
            // Simulated network quality stats
            // In real implementation, these would come from:
            // - SIP: PJSIP quality metrics
            // - GSM: TelephonyManager signal quality

            val stats = mapOf(
                "latencyMs" to 45,
                "jitterMs" to 5,
                "packetLossPercent" to 0.1,
                "mos" to 4.2,
                "codec" to "G.711",
                "bandwidthKbps" to 64
            )

            Log.d(TAG, "getNetworkQualityStats: MOS=4.2, Latency=45ms")
            result.success(stats)

        } catch (e: Exception) {
            Log.e(TAG, "Error getting network quality stats", e)
            result.error("GET_NETWORK_QUALITY_STATS_ERROR", "Failed to get network quality stats: ${e.message}", e)
        }
    }

    /**
     * Get bridge call status
     */
    private fun getBridgeCallStatus(call: MethodCall, result: Result) {
        Log.d(TAG, "getBridgeCallStatus() called: callId=${call.argument<String>("callId")}")

        try {
            // Simulated bridge call status
            // In real implementation, this would query:
            // - SIP call state from PJSIP
            // - GSM call state from TelephonyManager

            val callId = call.argument<String>("callId") ?: ""

            val status = mapOf(
                "callId" to callId,
                "sipLegConnected" to true,
                "gsmLegConnected" to true,
                "bridgeActive" to true,
                "sipLegDuration" to 154, // seconds
                "gsmLegDuration" to 150, // seconds
                "sipStats" to mapOf(
                    "latencyMs" to 45,
                    "jitterMs" to 5,
                    "packetLossPercent" to 0.1,
                    "mos" to 4.2,
                    "codec" to "G.711",
                    "bandwidthKbps" to 64
                ),
                "gsmStats" to mapOf(
                    "latencyMs" to 30,
                    "jitterMs" to 3,
                    "packetLossPercent" to 0.05,
                    "mos" to 4.5,
                    "codec" to "AMR",
                    "bandwidthKbps" to 12
                )
            )

            Log.d(TAG, "getBridgeCallStatus: Bridge active")
            result.success(status)

        } catch (e: Exception) {
            Log.e(TAG, "Error getting bridge call status", e)
            result.error("GET_BRIDGE_CALL_STATUS_ERROR", "Failed to get bridge call status: ${e.message}", e)
        }
    }

    /**
     * Get audio levels for active call
     */
    private fun getAudioLevels(result: Result) {
        Log.d(TAG, "getAudioLevels() called")

        try {
            // Simulated audio levels
            // In real implementation, these would come from:
            // - AudioRecord for TX levels
            // - AudioTrack for RX levels

            val levels = mapOf(
                "sipTx" to 0.75, // -6 dB
                "sipRx" to 0.50, // -12 dB
                "gsmTx" to 0.65, // -9 dB
                "gsmRx" to 0.50  // -12 dB
            )

            Log.d(TAG, "getAudioLevels: SIP TX=${levels["sipTx"]}, RX=${levels["sipRx"]}")
            result.success(levels)

        } catch (e: Exception) {
            Log.e(TAG, "Error getting audio levels", e)
            result.error("GET_AUDIO_LEVELS_ERROR", "Failed to get audio levels: ${e.message}", e)
        }
    }

    /**
     * Initiate bridge call (SIP → GSM)
     */
    private fun initiateBridgeCall(call: MethodCall, result: Result) {
        Log.d(TAG, "initiateBridgeCall() called: ${call.argument<String>("phoneNumber")} via ${call.argument<String>("sipUri")}")

        try {
            val phoneNumber = call.argument<String>("phoneNumber") ?: ""
            val sipUri = call.argument<String>("sipUri") ?: ""

            // Store callback
            synchronized(callbackLock) {
                if (bridgeCallCallback != null) {
                    Log.w(TAG, "initiateBridgeCall: Another call in progress")
                    result.error("CALL_IN_PROGRESS", "Another bridge call is in progress", null)
                    return
                }
                bridgeCallCallback = result
            }

            // Bridge call initiation:
            // 1. Initiate SIP call leg
            // 2. Initiate GSM call leg
            // 3. Bridge audio streams

            // For now, simulate successful initiation
            Log.d(TAG, "initiateBridgeCall: Bridge call initiated (simulated)")

            synchronized(callbackLock) {
                bridgeCallCallback?.success(true)
                bridgeCallCallback = null
            }

        } catch (e: Exception) {
            Log.e(TAG, "Error initiating bridge call", e)
            synchronized(callbackLock) {
                bridgeCallCallback?.error("INITIATE_BRIDGE_CALL_ERROR", "Failed to initiate bridge call: ${e.message}", e)
                bridgeCallCallback = null
            }
        }
    }

    // ========================================================================
    // Helper Methods
    // ========================================================================

    private fun getSipRegistrationStatus(): Boolean {
        // In real implementation, check PJSIP registration status
        // For now, return true (simulated)
        return true
    }

    private fun getGsmSignalStrength(simSlot: Int): Int {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // Android 10+
                val signalStrength = telephonyManager?.signalStrength
                signalStrength?.dbm?.let { dbm ->
                    // Convert dBm to percentage (approximate)
                    // -50 dBm = 100%, -110 dBm = 0%
                    ((dbm + 110) / 60.0 * 100).toInt().coerceIn(0, 100)
                } ?: 0
            } else {
                // Pre-Q Android
                val gsmSignal = telephonyManager?.gsmSignalStrength ?: 0
                // ASU to percentage (0-31 ASU = 0-100%)
                (gsmSignal / 31.0 * 100).toInt().coerceIn(0, 100)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error getting GSM signal strength", e)
            0
        }
    }

    private fun getGsmNetworkType(simSlot: Int): String {
        return try {
            val networkType = telephonyManager?.networkType ?: TelephonyManager.NETWORK_TYPE_UNKNOWN
            when (networkType) {
                TelephonyManager.NETWORK_TYPE_GPRS,
                TelephonyManager.NETWORK_TYPE_EDGE -> "2G"
                TelephonyManager.NETWORK_TYPE_UMTS,
                TelephonyManager.NETWORK_TYPE_HSDPA,
                TelephonyManager.NETWORK_TYPE_HSUPA,
                TelephonyManager.NETWORK_TYPE_HSPA -> "3G"
                TelephonyManager.NETWORK_TYPE_LTE -> "4G"
                TelephonyManager.NETWORK_TYPE_NR -> "5G"
                else -> "Unknown"
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error getting GSM network type", e)
            "Unknown"
        }
    }

    private fun isDualSim(): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                telephonyManager?.activeModemCount ?: 1 > 1
            } else {
                // Pre-Q: Check for second SIM slot (implementation varies by manufacturer)
                false // Conservative default
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error checking dual SIM", e)
            false
        }
    }
}
