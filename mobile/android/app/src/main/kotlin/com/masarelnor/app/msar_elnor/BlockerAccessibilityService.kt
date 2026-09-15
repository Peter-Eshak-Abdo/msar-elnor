package com.masarelnor.app.msar_elnor

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Handler
import android.os.Looper
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.widget.Toast
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class BlockerAccessibilityService : AccessibilityService() {

    companion object {
        const val PREFS_NAME = "msar_elnor_blocker_prefs"
        const val KEY_BLOCKED_URLS = "blocked_urls"
        const val KEY_START_TIME = "start_time"
        const val KEY_END_TIME = "end_time"
        const val KEY_FALLBACK_URL = "fallback_url"
        const val KEY_IS_ACTIVE = "is_active"
        const val KEY_ANTI_TAMPER_ENABLED = "anti_tamper_enabled"
        const val KEY_AI_NSFW_ENABLED = "ai_nsfw_enabled"

        var isServiceRunning = false
        var isOverlayShowing = false
        var onBlockedDetectedListener: ((String) -> Unit)? = null

        fun updateRules(
            context: Context,
            blockedUrls: List<String>,
            startTime: String,
            endTime: String,
            fallbackUrl: String,
            isActive: Boolean
        ) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit()
                .putStringSet(KEY_BLOCKED_URLS, blockedUrls.toSet())
                .putString(KEY_START_TIME, startTime)
                .putString(KEY_END_TIME, endTime)
                .putString(KEY_FALLBACK_URL, fallbackUrl)
                .putBoolean(KEY_IS_ACTIVE, isActive)
                .apply()
        }

        fun reportOverlayClosed() {
            isOverlayShowing = false
        }
    }

    private lateinit var prefs: SharedPreferences
    private var lastTriggerTime: Long = 0

    override fun onServiceConnected() {
        super.onServiceConnected()
        try {
            isServiceRunning = true
            isOverlayShowing = false
            prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        } catch (t: Throwable) {
            t.printStackTrace()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        isServiceRunning = false
        isOverlayShowing = false
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        try {
            val packageName = event.packageName?.toString() ?: ""

            // 1. CRITICAL ANTI-FLICKER FIX: Never analyze our own application window!
            if (packageName.equals("com.masarelnor.app.msar_elnor", ignoreCase = true)) {
                return
            }

            // 2. CRITICAL ANTI-LOOP FIX: If overlay is actively showing, ignore events to prevent flicker loops
            if (isOverlayShowing) {
                return
            }

            // 3. ANTI-TAMPER & UNINSTALL PROTECTION: Prevent removing app or disabling admin
            if (handleAntiTamperWatchdog(packageName, event)) {
                return
            }

            // 4. Time & Active Rules Check
            val isActive = prefs.getBoolean(KEY_IS_ACTIVE, true)
            if (!isActive) return

            val startTime = prefs.getString(KEY_START_TIME, "23:00") ?: "23:00"
            val endTime = prefs.getString(KEY_END_TIME, "07:00") ?: "07:00"

            if (!isCurrentTimeInActiveHours(startTime, endTime)) {
                return
            }

            // Debounce check (800ms)
            val now = System.currentTimeMillis()
            if (now - lastTriggerTime < 800) return

            val blockedSet = prefs.getStringSet(
                KEY_BLOCKED_URLS,
                setOf("facebook.com", "tiktok.com", "instagram.com", "x.com", "twitter.com", "youtube.com/shorts", "reddit.com")
            ) ?: emptySet()

            var detectedBlockedItem: String? = null

            // 5. Direct App Package matching
            for (item in blockedSet) {
                val cleanItem = item.lowercase(Locale.ROOT)
                if (packageName.contains(cleanItem) || isPackageMatchingDomain(packageName, cleanItem)) {
                    detectedBlockedItem = item
                    break
                }
            }

            // 6. Deep Node Inspection across visible content and URL fields
            if (detectedBlockedItem == null && rootInActiveWindow != null) {
                val capturedText = extractTextFromNodes(rootInActiveWindow)
                
                // Match blocked list
                for (item in blockedSet) {
                    val cleanItem = item.lowercase(Locale.ROOT)
                    if (capturedText.contains(cleanItem)) {
                        detectedBlockedItem = item
                        break
                    }
                }

                // AI / Heuristic NSFW and extreme distraction keyword detection
                if (detectedBlockedItem == null && isExplicitKeywordPresent(capturedText)) {
                    detectedBlockedItem = "محتوى مشبوه محظور (رصد ذكي)"
                }
            }

            // 7. Execute Anti-Flicker Interception with Dopamine Redirect
            if (detectedBlockedItem != null) {
                lastTriggerTime = now
                isOverlayShowing = true
                executeSmoothDopamineRedirect(detectedBlockedItem)
            }
        } catch (t: Throwable) {
            // Guard against any crash in accessibility service
            t.printStackTrace()
        }
    }

    private fun handleAntiTamperWatchdog(packageName: String, event: AccessibilityEvent): Boolean {
        try {
            val lowerPkg = packageName.lowercase(Locale.ROOT)
            val isSettingsOrInstaller = lowerPkg.contains("packageinstaller") ||
                    lowerPkg.contains("settings") ||
                    lowerPkg.contains("deviceadmin")

            if (isSettingsOrInstaller && rootInActiveWindow != null) {
                val screenText = extractTextFromNodes(rootInActiveWindow)
                val refersToOurApp = screenText.contains("مسار النور") || screenText.contains("msar_elnor")

                if (refersToOurApp) {
                    val isTamperingAttempt = screenText.contains("إلغاء التثبيت") ||
                            screenText.contains("uninstall") ||
                            screenText.contains("إيقاف إجباري") ||
                            screenText.contains("force stop") ||
                            screenText.contains("مسح البيانات") ||
                            screenText.contains("clear data") ||
                            screenText.contains("إلغاء تفعيل") ||
                            screenText.contains("deactivate")

                    if (isTamperingAttempt) {
                        performGlobalAction(GLOBAL_ACTION_HOME)
                        Handler(Looper.getMainLooper()).post {
                            Toast.makeText(
                                applicationContext,
                                "🛡️ تطبيق مسار النور محمي ضد الإيقاف أو الحذف للحفاظ على مسارك وهدفك!",
                                Toast.LENGTH_LONG
                            ).show()
                        }
                        return true
                    }
                }
            }
        } catch (t: Throwable) {
            t.printStackTrace()
        }
        return false
    }

    private fun isExplicitKeywordPresent(text: String): Boolean {
        val nsfwKeywords = listOf(
            "porn", "xxx", "sex", "xvideos", "pornhub", "xnxx", "adult", "nude",
            "إباحي", "جنس", "سكس", "مواقع إباحية", "افلام للكبار", "شيميل"
        )
        for (kw in nsfwKeywords) {
            if (text.contains(kw)) return true
        }
        return false
    }

    private fun isPackageMatchingDomain(pkg: String, domain: String): Boolean {
        val lowerPkg = pkg.lowercase(Locale.ROOT)
        return when {
            domain.contains("facebook") && (lowerPkg.contains("katana") || lowerPkg.contains("facebook")) -> true
            domain.contains("tiktok") && (lowerPkg.contains("musically") || lowerPkg.contains("tiktok") || lowerPkg.contains("trill")) -> true
            domain.contains("instagram") && lowerPkg.contains("instagram") -> true
            (domain.contains("twitter") || domain.contains("x.com")) && (lowerPkg.contains("twitter") || lowerPkg.contains("com.twitter.android")) -> true
            domain.contains("reddit") && lowerPkg.contains("reddit") -> true
            domain.contains("snapchat") && lowerPkg.contains("snapchat") -> true
            domain.contains("shorts") && lowerPkg.contains("youtube") -> true
            else -> false
        }
    }

    private fun extractTextFromNodes(node: AccessibilityNodeInfo?): String {
        if (node == null) return ""
        val sb = StringBuilder()
        try {
            node.text?.let { sb.append(it.toString().lowercase(Locale.ROOT)).append(" ") }
            node.contentDescription?.let { sb.append(it.toString().lowercase(Locale.ROOT)).append(" ") }
            node.viewIdResourceName?.let {
                if (it.contains("url") || it.contains("address") || it.contains("search") || it.contains("omnibox") || it.contains("title")) {
                    node.text?.let { t -> sb.append(t.toString().lowercase(Locale.ROOT)).append(" ") }
                }
            }
            val count = node.childCount
            for (i in 0 until count) {
                val child = node.getChild(i)
                if (child != null) {
                    sb.append(extractTextFromNodes(child))
                }
            }
        } catch (_: Throwable) {}
        return sb.toString()
    }

    private fun executeSmoothDopamineRedirect(blockedTarget: String) {
        try {
            // 1. First trigger Home action so the background app is dismissed immediately without flicker
            performGlobalAction(GLOBAL_ACTION_HOME)

            // 2. Launch Dopamine Redirect Overlay Activity seamlessly
            Handler(Looper.getMainLooper()).postDelayed({
                try {
                    onBlockedDetectedListener?.invoke(blockedTarget)

                    val fallbackUrl = prefs.getString(
                        KEY_FALLBACK_URL,
                        "https://www.youtube.com/watch?v=aripsalin-tasbeha"
                    ) ?: "https://www.youtube.com/watch?v=aripsalin-tasbeha"

                    val intent = Intent(this, MainActivity::class.java).apply {
                        addFlags(
                            Intent.FLAG_ACTIVITY_NEW_TASK or
                            Intent.FLAG_ACTIVITY_CLEAR_TOP or
                            Intent.FLAG_ACTIVITY_SINGLE_TOP or
                            Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
                        )
                        putExtra("BLOCKED_TRIGGER", blockedTarget)
                        putExtra("FALLBACK_URL", fallbackUrl)
                        putExtra("IS_DOPAMINE_REDIRECT", true)
                    }
                    startActivity(intent)
                } catch (t: Throwable) {
                    isOverlayShowing = false
                    t.printStackTrace()
                }
            }, 200)
        } catch (t: Throwable) {
            isOverlayShowing = false
            t.printStackTrace()
        }
    }

    private fun isCurrentTimeInActiveHours(start: String, end: String): Boolean {
        try {
            val sdf = SimpleDateFormat("HH:mm", Locale.ROOT)
            val nowStr = SimpleDateFormat("HH:mm", Locale.ROOT).format(Date())
            val nowDate = sdf.parse(nowStr) ?: return true
            val startDate = sdf.parse(start) ?: return true
            val endDate = sdf.parse(end) ?: return true

            return if (startDate.after(endDate)) {
                nowDate.after(startDate) || nowDate.before(endDate) || nowDate == startDate
            } else {
                (nowDate.after(startDate) || nowDate == startDate) && nowDate.before(endDate)
            }
        } catch (e: Exception) {
            return true
        }
    }

    override fun onInterrupt() {
        isOverlayShowing = false
    }
}
