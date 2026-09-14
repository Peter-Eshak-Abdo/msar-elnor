package com.masarelnor.app.msar_elnor

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Handler
import android.os.Looper
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
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

        var isServiceRunning = false
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
    }

    private lateinit var prefs: SharedPreferences
    private var lastTriggerTime: Long = 0

    override fun onServiceConnected() {
        super.onServiceConnected()
        isServiceRunning = true
        prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    override fun onDestroy() {
        super.onDestroy()
        isServiceRunning = false
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        // 600ms debounce to strictly catch immediate re-open attempts
        val now = System.currentTimeMillis()
        if (now - lastTriggerTime < 600) return

        val isActive = prefs.getBoolean(KEY_IS_ACTIVE, true)
        if (!isActive) return

        val startTime = prefs.getString(KEY_START_TIME, "23:00") ?: "23:00"
        val endTime = prefs.getString(KEY_END_TIME, "07:00") ?: "07:00"

        if (!isCurrentTimeInActiveHours(startTime, endTime)) {
            return
        }

        val blockedSet = prefs.getStringSet(
            KEY_BLOCKED_URLS,
            setOf("facebook.com", "tiktok.com", "instagram.com", "x.com", "twitter.com", "youtube.com/shorts")
        ) ?: emptySet()

        val packageName = event.packageName?.toString() ?: ""
        var detectedBlockedItem: String? = null

        // 1. Direct App Package matching
        for (item in blockedSet) {
            val cleanItem = item.lowercase(Locale.ROOT)
            if (packageName.contains(cleanItem) || isPackageMatchingDomain(packageName, cleanItem)) {
                detectedBlockedItem = item
                break
            }
        }

        // 2. Deep text and URL bar inspection in browser / webview windows
        if (detectedBlockedItem == null && rootInActiveWindow != null) {
            val capturedText = extractTextFromNodes(rootInActiveWindow)
            for (item in blockedSet) {
                val cleanItem = item.lowercase(Locale.ROOT)
                if (capturedText.contains(cleanItem)) {
                    detectedBlockedItem = item
                    break
                }
            }
        }

        // 3. Strict Interception: Close Distraction and Launch Spiritual Fallback
        if (detectedBlockedItem != null) {
            lastTriggerTime = now
            executeStrictBlockAndSpiritualRedirect(detectedBlockedItem)
        }
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
        node.text?.let { sb.append(it.toString().lowercase(Locale.ROOT)).append(" ") }
        node.contentDescription?.let { sb.append(it.toString().lowercase(Locale.ROOT)).append(" ") }
        node.viewIdResourceName?.let {
            if (it.contains("url") || it.contains("address") || it.contains("search") || it.contains("omnibox")) {
                node.text?.let { t -> sb.append(t.toString().lowercase(Locale.ROOT)).append(" ") }
            }
        }
        val childCount = node.childCount
        for (i in 0 until childCount) {
            try {
                val child = node.getChild(i)
                if (child != null) {
                    sb.append(extractTextFromNodes(child))
                }
            } catch (_: Exception) {}
        }
        return sb.toString()
    }

    private fun executeStrictBlockAndSpiritualRedirect(blockedTarget: String) {
        // Immediate dismissal to home screen
        performGlobalAction(GLOBAL_ACTION_HOME)

        Handler(Looper.getMainLooper()).postDelayed({
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
            }
            startActivity(intent)
        }, 150)
    }

    private fun isCurrentTimeInActiveHours(start: String, end: String): Boolean {
        try {
            val sdf = SimpleDateFormat("HH:mm", Locale.ROOT)
            val nowStr = SimpleDateFormat("HH:mm", Locale.ROOT).format(Date())
            val nowDate = sdf.parse(nowStr) ?: return true
            val startDate = sdf.parse(start) ?: return true
            val endDate = sdf.parse(end) ?: return true

            return if (startDate.after(endDate)) {
                // Crosses midnight (e.g. 23:00 to 07:00)
                nowDate.after(startDate) || nowDate.before(endDate) || nowDate == startDate
            } else {
                // Daytime (e.g. 09:00 to 17:00)
                (nowDate.after(startDate) || nowDate == startDate) && nowDate.before(endDate)
            }
        } catch (e: Exception) {
            return true
        }
    }

    override fun onInterrupt() {}
}
