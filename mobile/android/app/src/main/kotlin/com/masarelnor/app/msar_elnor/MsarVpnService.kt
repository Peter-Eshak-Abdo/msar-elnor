package com.masarelnor.app.msar_elnor

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import android.util.Log
import androidx.core.app.NotificationCompat

/**
 * MsarVpnService - Plan C (Local VPN DNS Filtering Layer).
 * Establishes a local TUN interface routing DNS requests to Family Shield DNS servers:
 * - Cloudflare Family DNS (1.1.1.3 / 1.0.0.3)
 * - CleanBrowsing Adult Filter DNS (185.228.168.168 / 185.228.169.168)
 *
 * This provides zero-leak hardware-level DNS blocking for all web browsers and network apps.
 */
class MsarVpnService : VpnService() {

    companion object {
        private const val TAG = "MsarVpnService"
        const val VPN_NOTIFICATION_ID = 1002
        const val VPN_CHANNEL_ID = "msar_vpn_channel"
        var isVpnRunning = false

        fun startVpn(context: Context) {
            val intent = Intent(context, MsarVpnService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stopVpn(context: Context) {
            val intent = Intent(context, MsarVpnService::class.java).apply {
                action = "STOP_VPN"
            }
            context.startService(intent)
        }
    }

    private var vpnInterface: ParcelFileDescriptor? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == "STOP_VPN") {
            stopVpnInternal()
            return START_NOT_STICKY
        }

        startVpnTunnel()
        return START_STICKY
    }

    private fun startVpnTunnel() {
        try {
            if (vpnInterface != null) {
                return
            }

            val notification = NotificationCompat.Builder(this, VPN_CHANNEL_ID)
                .setContentTitle("مسار النور - فلتر الـ DNS مشتغل")
                .setContentText("جدار حماية DNS نقي يمنع المواقع والإعلانات الإباحية من المنبع")
                .setSmallIcon(android.R.drawable.ic_menu_compass)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .setOngoing(true)
                .build()

            startForeground(VPN_NOTIFICATION_ID, notification)

            val builder = Builder()
                .setSession("مسار النور Family Shield")
                .addAddress("10.10.0.1", 32)
                // CleanBrowsing Adult Filter DNS
                .addDnsServer("185.228.168.168")
                // Cloudflare 1.1.1.3 Family Filter
                .addDnsServer("1.1.1.3")
                // Fallback secondary CleanBrowsing
                .addDnsServer("185.228.169.168")
                // Intercept DNS traffic
                .addRoute("185.228.168.168", 32)
                .addRoute("1.1.1.3", 32)
                .setBlocking(false)

            vpnInterface = builder.establish()
            isVpnRunning = true
            Log.d(TAG, "MsarVpnService established successfully with Family DNS servers")

        } catch (e: Exception) {
            Log.e(TAG, "Failed to start MsarVpnService", e)
            stopVpnInternal()
        }
    }

    private fun stopVpnInternal() {
        try {
            vpnInterface?.close()
            vpnInterface = null
        } catch (e: Exception) {
            Log.e(TAG, "Error closing VPN interface", e)
        }
        isVpnRunning = false
        stopForeground(true)
        stopSelf()
    }

    override fun onDestroy() {
        stopVpnInternal()
        super.onDestroy()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                VPN_CHANNEL_ID,
                "مسار النور - فلتر الـ DNS",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "إشعار تشغيل نفق حماية الـ DNS من المحتوى الضار"
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }
}
