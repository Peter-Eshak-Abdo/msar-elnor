package com.masarelnor.app.msar_elnor

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent
import android.widget.Toast

class MsarDeviceAdminReceiver : DeviceAdminReceiver() {

    override fun onEnabled(context: Context, intent: Intent) {
        super.onEnabled(context, intent)
        Toast.makeText(context, "تم تفعيل حماية مسار النور كمدير للجهاز بنجاح", Toast.LENGTH_SHORT).show()
    }

    override fun onDisableRequested(context: Context, intent: Intent): CharSequence {
        return "تحذير: إلغاء صلاحية مدير الجهاز سيعطل الحماية الصارمة لمسار النور. هل أنت متأكد؟"
    }

    override fun onDisabled(context: Context, intent: Intent) {
        super.onDisabled(context, intent)
        Toast.makeText(context, "تم تعطيل صلاحية مدير الجهاز", Toast.LENGTH_SHORT).show()
    }
}
