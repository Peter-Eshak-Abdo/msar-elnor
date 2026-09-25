package com.masarelnor.app.msar_elnor

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * BootReceiver - Ensures automatic restart of the foreground protection service
 * across device reboots, package updates, and kill events.
 */
class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context?, intent: Intent?) {
        if (context == null || intent == null) return

        val action = intent.action
        Log.d("MsarBootReceiver", "Received broadcast action: $action")

        when (action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_LOCKED_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            "android.intent.action.QUICKBOOT_POWERON",
            "com.htc.intent.action.QUICKBOOT_POWERON",
            "com.masarelnor.app.RESTART_BLOCKER_SERVICE" -> {
                try {
                    // Layer 7: Safe Mode Check
                    val isSafeMode = context.packageManager.isSafeMode
                    if (isSafeMode) {
                        Log.w("MsarBootReceiver", "Layer 7 Warning: Device booted in SAFE MODE!")
                    }

                    // Start 24/7 Foreground Protection
                    BlockerForegroundService.startService(context)

                    // Start Family DNS VPN automatically
                    MsarVpnService.startVpn(context)
                } catch (e: Exception) {
                    Log.e("MsarBootReceiver", "Failed to start services on boot", e)
                }
            }
        }
    }
}
