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
            Intent.ACTION_MY_PACKAGE_REPLACED,
            "android.intent.action.QUICKBOOT_POWERON",
            "com.htc.intent.action.QUICKBOOT_POWERON",
            "com.masarelnor.app.RESTART_BLOCKER_SERVICE" -> {
                try {
                    BlockerForegroundService.startService(context)
                } catch (e: Exception) {
                    Log.e("MsarBootReceiver", "Failed to start BlockerForegroundService", e)
                }
            }
        }
    }
}
