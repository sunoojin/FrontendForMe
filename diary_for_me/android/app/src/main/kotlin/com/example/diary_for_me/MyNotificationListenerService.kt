package com.example.diary_for_me

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.os.Build
import android.os.Bundle
import android.util.Log

class MyNotificationListenerService : NotificationListenerService() {
    companion object {
        var instance: MyNotificationListenerService? = null
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        instance = this
        Log.i("MyNLS", "Listener connected")
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        instance = null
        Log.i("MyNLS", "Listener disconnected")
    }

    // 호출 시 activeNotifications을 직렬화해 List<Map<String, Any>>로 반환
    fun getActiveNotificationsSerializable(): List<Map<String, Any>> {
        val out = mutableListOf<Map<String, Any>>()
        try {
            val arr: Array<StatusBarNotification> = activeNotifications
            for (sbn in arr) {
                val n = sbn.notification
                val extras: Bundle? = n.extras
                val title = extras?.getString("android.title") ?: extras?.getString("title") ?: ""
                val text = extras?.getCharSequence("android.text")?.toString() ?: extras?.getCharSequence("text")?.toString() ?: ""
                val pkg = sbn.packageName ?: ""
                val postTime = sbn.postTime // long millis
                val map = mapOf<String, Any>(
                    "title" to title,
                    "text" to text,
                    "packageName" to pkg,
                    "postTime" to postTime
                )
                out.add(map)
            }
        } catch (e: Exception) {
            Log.e("MyNLS", "getActiveNotificationsSerializable error", e)
        }
        return out
    }
}
