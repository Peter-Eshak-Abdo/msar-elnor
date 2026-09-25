package com.masarelnor.app.msar_elnor

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat

/**
 * BlockerForegroundService - Ensures uninterrupted 24/7 protection.
 * Runs as a Foreground Service with a persistent notification to prevent Android OS kill.
 * Also houses Plan B (UsageStatsManager watchdog polling loop).
 */
class BlockerForegroundService : Service() {

    companion object {
        const val CHANNEL_ID = "msar_elnor_foreground_channel"
        const val NOTIFICATION_ID = 1001
        var isServiceRunning = false

        fun startService(context: Context) {
            val intent = Intent(context, BlockerForegroundService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stopService(context: Context) {
            val intent = Intent(context, BlockerForegroundService::class.java)
            context.stopService(intent)
        }
    }

    private val watchdogHandler = Handler(Looper.getMainLooper())
    private var isWatchdogActive = false
    private var lastTriggerTime: Long = 0

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        val notification = buildNotification()
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(
                    NOTIFICATION_ID,
                    notification,
                    android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
                )
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
        } catch (e: Exception) {
            e.printStackTrace()
            try {
                startForeground(NOTIFICATION_ID, notification)
            } catch (ignored: Exception) {}
        }
        isServiceRunning = true
        startPlanBWatchdog()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        isServiceRunning = false
        stopPlanBWatchdog()
        // If unexpectedly killed, request restart
        val restartIntent = Intent("com.masarelnor.app.RESTART_BLOCKER_SERVICE")
        sendBroadcast(restartIntent)
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "حماية مسار النور المستمرة",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "خدمة المراقبة والحماية الثلاثية ضد المحتوى المشتت والضار"
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        val launchIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("مسار النور - درع الحماية نشط")
            .setContentText("الحماية الثلاثية تعمل باستمرار لحفظ مسارك وصفاء ذهنك")
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    /**
     * Plan B: UsageStatsManager Watchdog.
     * Polls foreground application every 1.5 seconds if Accessibility Service ever lags or gets paused.
     */
    private fun startPlanBWatchdog() {
        if (isWatchdogActive) return
        isWatchdogActive = true

        val watchdogRunnable = object : Runnable {
            override fun run() {
                if (!isWatchdogActive) return
                try {
                    checkForegroundAppPlanB()
                } catch (e: Exception) {
                    e.printStackTrace()
                }
                watchdogHandler.postDelayed(this, 1500)
            }
        }
        watchdogHandler.postDelayed(watchdogRunnable, 1500)
    }

    private fun stopPlanBWatchdog() {
        isWatchdogActive = false
        watchdogHandler.removeCallbacksAndMessages(null)
    }

    private fun checkForegroundAppPlanB() {
        // Layer 10: Fallback Loop (If Accessibility is turned off/killed, VPN cuts off internet)
        val prefs = getSharedPreferences(BlockerAccessibilityService.PREFS_NAME, Context.MODE_PRIVATE)
        val isActive = prefs.getBoolean(BlockerAccessibilityService.KEY_IS_ACTIVE, true)

        if (isActive) {
            val isAccRunning = BlockerAccessibilityService.isServiceRunning
            if (!isAccRunning && !MsarVpnService.isKillSwitchActive) {
                // Engage Fallback Loop Kill Switch!
                Log.w("BlockerForeground", "Fallback Loop Triggered: Accessibility is dead! Engaging Kill Switch.")
                MsarVpnService.setKillSwitch(this, true)
            } else if (isAccRunning && MsarVpnService.isKillSwitchActive) {
                // Restore normal Family Shield VPN
                Log.i("BlockerForeground", "Accessibility is restored! Disengaging Kill Switch.")
                MsarVpnService.setKillSwitch(this, false)
            }
        }

        // Only run Plan B fallback if overlay is NOT showing
        if (BlockerAccessibilityService.isOverlayShowing) return
        if (!isActive) return

        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager ?: return
        val time = System.currentTimeMillis()
        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            time - 1000 * 10,
            time
        )

        if (stats.isNullOrEmpty()) return

        // Find the most recently used app package
        val recentApp = stats.maxByOrNull { it.lastTimeUsed } ?: return
        val topPackage = recentApp.packageName ?: return

        // Ignore our own package and system launcher
        if (topPackage == packageName || topPackage.contains("launcher") || topPackage.contains("systemui")) {
            return
        }

        val blockedSet = prefs.getStringSet(
            BlockerAccessibilityService.KEY_BLOCKED_URLS,
            emptySet()
        ) ?: emptySet()

        val matched = blockedSet.firstOrNull { topPackage.contains(it.replace(".com", ""), ignoreCase = true) }
        if (matched != null) {
            val now = System.currentTimeMillis()
            if (now - lastTriggerTime > 2000) {
                lastTriggerTime = now
                triggerPlanBFallback(matched)
            }
        }
    }

    private fun triggerPlanBFallback(matchedTarget: String) {
        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(homeIntent)

        val overlayIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            putExtra("BLOCKED_TRIGGER", "Plan B Watchdog: $matchedTarget")
            putExtra("FALLBACK_URL", "https://www.youtube.com/watch?v=aripsalin-tasbeha")
        }
        startActivity(overlayIntent)
    }
}
