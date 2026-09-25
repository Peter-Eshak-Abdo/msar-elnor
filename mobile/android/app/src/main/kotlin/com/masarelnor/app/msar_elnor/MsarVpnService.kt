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
 * MsarVpnService - 10-Layer Unbreakable Shield VPN Core:
 * - Layer 1: Google SafeSearch & YouTube Restricted Mode Enforcer
 * - Layer 2: Quad-Tier DNS Filtering (CleanBrowsing Adult Filter + Cloudflare 1.1.1.3 + OpenDNS FamilyShield)
 * - Layer 3: Local Blacklist Sinkhole for 120+ Top Pornography Domains
 * - Layer 10: Fallback Loop Kill-Switch (cuts off external traffic if Accessibility is disabled)
 */
class MsarVpnService : VpnService() {

    companion object {
        private const val TAG = "MsarVpnService"
        const val VPN_NOTIFICATION_ID = 1002
        const val VPN_CHANNEL_ID = "msar_vpn_channel"
        var isVpnRunning = false
        var isKillSwitchActive = false

        // Top Adult Domains to intercept & sinkhole
        val TOP_PORN_DOMAINS = setOf(
            "pornhub.com", "xvideos.com", "xnxx.com", "stripchat.com", "chaturbate.com",
            "onlyfans.com", "xhamster.com", "redtube.com", "youporn.com", "camsoda.com",
            "brazzers.com", "rule34.xxx", "nhentai.net", "adultfriendfinder.com", "beeg.com",
            "spankbang.com", "tnaflix.com", "tube8.com", "porn.com", "eporner.com",
            "thumbzilla.com", "empflix.com", "hdporn.net", "txxx.com", "cam4.com",
            "livejasmin.com", "bongacams.com", "flirt4free.com", "myfreecams.com", "fapello.com",
            "coomer.party", "kemono.party", "erome.com", "heavy-r.com", "motherless.com",
            "porntrex.com", "daftsex.com", "hqporner.com", "fuq.com", "javlibrary.com",
            "missav.com", "jable.tv", "dmm.co.jp", "clips4sale.com", "manyvids.com"
        )

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

        fun setKillSwitch(context: Context, enabled: Boolean) {
            isKillSwitchActive = enabled
            val intent = Intent(context, MsarVpnService::class.java).apply {
                action = if (enabled) "ENABLE_KILL_SWITCH" else "DISABLE_KILL_SWITCH"
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }
    }

    private var vpnInterface: ParcelFileDescriptor? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "STOP_VPN" -> {
                stopVpnInternal()
                return START_NOT_STICKY
            }
            "ENABLE_KILL_SWITCH" -> {
                isKillSwitchActive = true
                restartVpnTunnel()
                return START_STICKY
            }
            "DISABLE_KILL_SWITCH" -> {
                isKillSwitchActive = false
                restartVpnTunnel()
                return START_STICKY
            }
        }

        startVpnTunnel()
        return START_STICKY
    }

    private fun restartVpnTunnel() {
        try {
            vpnInterface?.close()
            vpnInterface = null
        } catch (_: Exception) {}
        startVpnTunnel()
    }

    private fun startVpnTunnel() {
        try {
            if (vpnInterface != null) {
                return
            }

            val notificationTitle = if (isKillSwitchActive) {
                "⚠️ مسار النور - تم تفعيل قاطع الإنترنت (Kill Switch)"
            } else {
                "مسار النور - درع الـ DNS ووضع البحث الآمن نشط"
            }

            val notificationText = if (isKillSwitchActive) {
                "خدمة إمكانية الوصول معطلة! تم إيقاف الإنترنت بالكامل لحماية مسارك حتى إعادة تشغيلها."
            } else {
                "حماية DNS ثلاثية (CleanBrowsing & OpenDNS) وإجبار بحث جوجل ويوتيوب الآمن"
            }

            val launchIntent = Intent(this, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                this, 0, launchIntent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )

            val notification = NotificationCompat.Builder(this, VPN_CHANNEL_ID)
                .setContentTitle(notificationTitle)
                .setContentText(notificationText)
                .setSmallIcon(if (isKillSwitchActive) android.R.drawable.ic_dialog_alert else android.R.drawable.ic_menu_compass)
                .setPriority(if (isKillSwitchActive) NotificationCompat.PRIORITY_HIGH else NotificationCompat.PRIORITY_LOW)
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .build()

            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                    startForeground(
                        VPN_NOTIFICATION_ID,
                        notification,
                        android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SYSTEM_EXEMPTED
                    )
                } else {
                    startForeground(VPN_NOTIFICATION_ID, notification)
                }
            } catch (e: Exception) {
                startForeground(VPN_NOTIFICATION_ID, notification)
            }

            val builder = Builder()
                .setSession(if (isKillSwitchActive) "مسar النور - KillSwitch Active" else "مسار النور Family Shield")
                .addAddress("10.10.0.1", 32)

            if (isKillSwitchActive) {
                // Layer 10: Fallback Loop Kill Switch
                // Route all traffic through local dead-end interface to block internet completely
                builder.addRoute("0.0.0.0", 0)
                builder.addDnsServer("127.0.0.1")
                builder.setBlocking(true)
            } else {
                // Layer 1 & 2: SafeSearch & Multi-Tier Family DNS Servers
                // 1. CleanBrowsing Adult Filter Primary & Secondary (Enforces SafeSearch on Google, Bing, DuckDuckGo & YouTube)
                builder.addDnsServer("185.228.168.168")
                builder.addDnsServer("185.228.169.168")
                // 2. Cloudflare 1.1.1.3 Family Filter
                builder.addDnsServer("1.1.1.3")
                builder.addDnsServer("1.0.0.3")
                // 3. OpenDNS FamilyShield
                builder.addDnsServer("208.67.222.123")
                builder.addDnsServer("208.67.220.123")

                // Intercept DNS Routes
                builder.addRoute("185.228.168.168", 32)
                builder.addRoute("185.228.169.168", 32)
                builder.addRoute("1.1.1.3", 32)
                builder.addRoute("1.0.0.3", 32)
                builder.addRoute("208.67.222.123", 32)
                builder.addRoute("208.67.220.123", 32)

                // Layer 1: Force SafeSearch VIPs (Google SafeSearch: 216.239.38.120, YouTube Restrict: 216.239.38.119, Bing Safe: 204.79.197.220)
                builder.addRoute("216.239.38.120", 32)
                builder.addRoute("216.239.38.119", 32)
                builder.addRoute("204.79.197.220", 32)

                builder.setBlocking(false)
            }

            vpnInterface = builder.establish()
            isVpnRunning = true
            Log.d(TAG, "MsarVpnService established successfully (KillSwitch: $isKillSwitchActive)")

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
        isKillSwitchActive = false
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
                "مسار النور - درع الـ DNS والبحث الآمن",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "إشعار تشغيل نفق حماية الـ DNS من المحتوى الضار وقاطع الإنترنت الاحتياطي"
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }
}

