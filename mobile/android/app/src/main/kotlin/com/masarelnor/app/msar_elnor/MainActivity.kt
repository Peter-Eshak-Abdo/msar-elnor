package com.masarelnor.app.msar_elnor

import android.app.AppOpsManager
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.net.VpnService
import android.os.Build
import android.os.PowerManager
import android.os.Process
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.masarelnor.app/blocker"
    private var methodChannel: MethodChannel? = null
    private lateinit var devicePolicyManager: DevicePolicyManager
    private lateinit var adminComponent: ComponentName
    private val VPN_REQUEST_CODE = 2001

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        adminComponent = ComponentName(this, MsarDeviceAdminReceiver::class.java)

        // Automatically start the persistent 24/7 foreground protection service
        try {
            BlockerForegroundService.startService(this)
        } catch (e: Exception) {
            e.printStackTrace()
        }

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                // 1. Accessibility Service Check & Launch
                "isAccessibilityEnabled" -> {
                    result.success(isAccessibilityServiceEnabled(context, BlockerAccessibilityService::class.java))
                }
                "openAccessibilitySettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ACC_ERROR", e.message, null)
                    }
                }

                // 2. Device Admin Check & Intent Fix
                "isDeviceAdminActive" -> {
                    result.success(devicePolicyManager.isAdminActive(adminComponent))
                }
                "requestDeviceAdmin" -> {
                    try {
                        val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
                            putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, adminComponent)
                            putExtra(
                                DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                                "تفعيل صلاحية مسؤول الجهاز تمنع مسح التطبيق أو تعطيل الحماية إلا عبر لوحة تحكم الويب."
                            )
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ADMIN_ERROR", e.message, null)
                    }
                }

                // 3. DNS Settings Button Fix (ACTION_VPN_SETTINGS with fallback to ACTION_WIRELESS_SETTINGS)
                "openDnsSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_VPN_SETTINGS).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        try {
                            val fallbackIntent = Intent(Settings.ACTION_WIRELESS_SETTINGS).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(fallbackIntent)
                            result.success(true)
                        } catch (e2: Exception) {
                            try {
                                val generalSettings = Intent(Settings.ACTION_SETTINGS).apply {
                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                }
                                startActivity(generalSettings)
                                result.success(true)
                            } catch (e3: Exception) {
                                result.error("DNS_ERROR", e3.message, null)
                            }
                        }
                    }
                }

                // 4. Battery Optimization Whitelist (Anti-Kill 24/7)
                "isIgnoringBatteryOptimizations" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                        result.success(pm.isIgnoringBatteryOptimizations(packageName))
                    } else {
                        result.success(true)
                    }
                }
                "requestIgnoreBatteryOptimizations" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        try {
                            val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                            if (!pm.isIgnoringBatteryOptimizations(packageName)) {
                                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                                    data = Uri.parse("package:$packageName")
                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                }
                                startActivity(intent)
                            }
                            result.success(true)
                        } catch (e: Exception) {
                            try {
                                val fallbackIntent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                }
                                startActivity(fallbackIntent)
                                result.success(true)
                            } catch (e2: Exception) {
                                result.error("BATTERY_ERROR", e2.message, null)
                            }
                        }
                    } else {
                        result.success(true)
                    }
                }

                // 5. UsageStats Permission (Plan B Watchdog)
                "isUsageStatsGranted" -> {
                    result.success(hasUsageStatsPermission())
                }
                "requestUsageStatsPermission" -> {
                    try {
                        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("USAGE_STATS_ERROR", e.message, null)
                    }
                }

                // 6. Plan C: Local VPN DNS Filter
                "isVpnActive" -> {
                    result.success(MsarVpnService.isVpnRunning)
                }
                "startVpnService" -> {
                    try {
                        val vpnIntent = VpnService.prepare(this)
                        if (vpnIntent != null) {
                            startActivityForResult(vpnIntent, VPN_REQUEST_CODE)
                            result.success(false)
                        } else {
                            MsarVpnService.startVpn(this)
                            result.success(true)
                        }
                    } catch (e: Exception) {
                        result.error("VPN_ERROR", e.message, null)
                    }
                }
                "stopVpnService" -> {
                    MsarVpnService.stopVpn(this)
                    result.success(true)
                }

                // 7. Foreground Service Management
                "startForegroundProtection" -> {
                    BlockerForegroundService.startService(this)
                    result.success(true)
                }
                "isForegroundServiceRunning" -> {
                    result.success(BlockerForegroundService.isServiceRunning)
                }

                // 8. Overlay Permission
                "requestOverlayPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(context)) {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        ).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(false)
                    } else {
                        result.success(true)
                    }
                }

                // 9. Sync Rules
                "updateRules" -> {
                    val blockedUrls = call.argument<List<String>>("blockedUrls") ?: emptyList()
                    val startTime = call.argument<String>("startTime") ?: "23:00"
                    val endTime = call.argument<String>("endTime") ?: "07:00"
                    val fallbackUrl = call.argument<String>("fallbackUrl") ?: "https://www.youtube.com/watch?v=aripsalin-tasbeha"
                    val isActive = call.argument<Boolean>("isActive") ?: true

                    BlockerAccessibilityService.updateRules(
                        context,
                        blockedUrls,
                        startTime,
                        endTime,
                        fallbackUrl,
                        isActive
                    )
                    result.success(true)
                }
                "reportOverlayClosed" -> {
                    BlockerAccessibilityService.reportOverlayClosed()
                    result.success(true)
                }
                "triggerSpiritualEmergency" -> {
                    val target = call.argument<String>("target") ?: "اختبار الحظر"
                    val fallback = call.argument<String>("fallbackUrl") ?: "https://www.youtube.com/watch?v=aripsalin-tasbeha"
                    notifyFlutterBlockedEvent(target, fallback)
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Attach listener from Service
        BlockerAccessibilityService.onBlockedDetectedListener = { blockedItem ->
            runOnUiThread {
                notifyFlutterBlockedEvent(blockedItem, "https://www.youtube.com/watch?v=aripsalin-tasbeha")
            }
        }

        // Handle intent if launched directly from service
        intent?.let { checkIncomingIntent(it) }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == VPN_REQUEST_CODE && resultCode == RESULT_OK) {
            MsarVpnService.startVpn(this)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        checkIncomingIntent(intent)
    }

    private fun checkIncomingIntent(intent: Intent) {
        val blockedTarget = intent.getStringExtra("BLOCKED_TRIGGER")
        val fallbackUrl = intent.getStringExtra("FALLBACK_URL")
        if (blockedTarget != null) {
            notifyFlutterBlockedEvent(blockedTarget, fallbackUrl ?: "")
        }
    }

    private fun notifyFlutterBlockedEvent(target: String, fallbackUrl: String) {
        methodChannel?.invokeMethod("onBlockerTriggered", mapOf(
            "target" to target,
            "fallbackUrl" to fallbackUrl,
            "timestamp" to System.currentTimeMillis()
        ))
    }

    private fun isAccessibilityServiceEnabled(context: Context, service: Class<*>): Boolean {
        val expectedComponentName = "${context.packageName}/${service.name}"
        val enabledServicesSetting = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false

        val colonSplitter = TextUtils.SimpleStringSplitter(':')
        colonSplitter.setString(enabledServicesSetting)

        while (colonSplitter.hasNext()) {
            val componentName = colonSplitter.next()
            if (componentName.equals(expectedComponentName, ignoreCase = true)) {
                return true
            }
        }
        return false
    }

    private fun hasUsageStatsPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                appOps.unsafeCheckOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    Process.myUid(),
                    packageName
                )
            } else {
                appOps.checkOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    Process.myUid(),
                    packageName
                )
            }
            mode == AppOpsManager.MODE_ALLOWED
        } else {
            true
        }
    }
}
