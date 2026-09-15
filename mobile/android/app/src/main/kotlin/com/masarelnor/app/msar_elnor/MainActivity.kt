package com.masarelnor.app.msar_elnor

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.masarelnor.app/blocker"
    private var methodChannel: MethodChannel? = null
    private lateinit var devicePolicyManager: DevicePolicyManager
    private lateinit var adminComponent: ComponentName

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        adminComponent = ComponentName(this, MsarDeviceAdminReceiver::class.java)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityEnabled" -> {
                    result.success(isAccessibilityServiceEnabled(context, BlockerAccessibilityService::class.java))
                }
                "openAccessibilitySettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "isDeviceAdminActive" -> {
                    result.success(devicePolicyManager.isAdminActive(adminComponent))
                }
                "requestDeviceAdmin" -> {
                    val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
                        putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, adminComponent)
                        putExtra(
                            DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                            "تفعيل صلاحية مدير الجهاز تمنع مسح أو إيقاف تطبيق مسار النور لحماية مسارك وأهدافك."
                        )
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    startActivity(intent)
                    result.success(true)
                }
                "openDnsSettings" -> {
                    try {
                        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            Intent(Settings.ACTION_WIRELESS_SETTINGS).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                        } else {
                            Intent(Settings.ACTION_SETTINGS).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
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
}
