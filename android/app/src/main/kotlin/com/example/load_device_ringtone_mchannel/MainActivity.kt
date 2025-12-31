package com.example.load_device_ringtone_mchannel

import android.content.Context
import android.database.Cursor
import android.media.RingtoneManager
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = "flutter_channel"
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getRingtones" -> {
                        val ringtones = getAllRingtones(this)
                        result.success(ringtones)
                    }
                    "playRingtone" -> {
                        val title = call.argument<String>("title")
                        val success = playRingtoneByTitle(title)
                        result.success(success)
                    }
                }
            }
    }

    private fun getAllRingtones(context: Context): List<Map<String, String>> {
        val manager = RingtoneManager(context)
        manager.setType(RingtoneManager.TYPE_RINGTONE)
        val cursor = manager.cursor
        val list = mutableListOf<Map<String, String>>()

        cursor?.use {
            while (it.moveToNext()) {
                val title = it.getString(RingtoneManager.TITLE_COLUMN_INDEX)
                val uri = manager.getRingtoneUri(it.position)
                list.add(
                    mapOf(
                        "title" to title,
                        "uri" to (uri?.toString() ?: "")
                    )
                )
            }
        }
        return list
    }

    private fun playRingtoneByTitle(title: String?): Boolean {
        val manager = RingtoneManager(this)
        manager.setType(RingtoneManager.TYPE_RINGTONE)
        val cursor = manager.cursor

        cursor?.use {
            while (it.moveToNext()) {
                if (it.getString(RingtoneManager.TITLE_COLUMN_INDEX) == title) {
                    val uri = manager.getRingtoneUri(it.position)
                    val ringtone = RingtoneManager.getRingtone(this, uri)
                    ringtone?.play()
                    return true
                }
            }
        }
        return false
    }
}
