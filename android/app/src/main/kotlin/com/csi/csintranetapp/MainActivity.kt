package com.csi.csintranetapp

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import androidx.core.content.ContextCompat.getSystemService
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine


import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

import com.onesignal.OSNotification
import com.onesignal.OSMutableNotification
import com.onesignal.OSNotificationReceivedEvent
import com.onesignal.OneSignal.OSRemoteNotificationReceivedHandler
import org.json.JSONObject

class MainActivity: FlutterActivity() {
    private val CHANNEL = "flutter.native/notihelper"
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler{ call, result ->
            if (call.method == "getNotiUrl") {
                var res = NotificationUrl.notiUrl
                result.success(res)
            }
        }
    }

}

class RemoteNotificationReceivedHandler : OSRemoteNotificationReceivedHandler {
//    override fun onNotificationProcessing(receivedResult: OSNotificationReceivedResult): Boolean {
//
//
//        val url = receivedResult.payload.additionalData["url"]
//        Log.e("url",url)
//        NotificationUrl.setUrl(receivedResult.payload.additionalData.getString("url"))
//        return false
//    }

    override fun remoteNotificationReceived(
        context: Context?,
        notificationReceivedEvent: OSNotificationReceivedEvent?
    ) {

        val notification = notificationReceivedEvent!!.notification
        val mutableNotification = notification.mutableCopy()
        val data: JSONObject = notification.additionalData
        val url = data.toString()
        NotificationUrl.setUrl(url)
        Log.i("OneSignalExample", "Received Notification Data: $data")

        // If complete isn't call within a time period of 25 seconds, OneSignal internal logic will show the original notification
        // To omit displaying a notification, pass `null` to complete()

        // If complete isn't call within a time period of 25 seconds, OneSignal internal logic will show the original notification
        // To omit displaying a notification, pass `null` to complete()
        notificationReceivedEvent.complete(mutableNotification)
    }
}

object NotificationUrl {
    var notiUrl = ""
    fun setUrl(url: String) {
        notiUrl = url
    }
}
