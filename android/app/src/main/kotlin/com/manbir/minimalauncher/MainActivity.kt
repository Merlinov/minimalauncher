package com.manbir.minimalauncher

import android.app.Application
import android.app.NotificationManager
import android.app.SearchManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Bundle
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode.transparent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    
    private val TAG = "MainChannel"
    private val CHANNEL = "main_channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        intent.putExtra("background_mode", transparent.toString())
        super.onCreate(savedInstanceState)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            // Request the WRITE_SETTINGS permission for Android 6.0 and higher
            if (!Settings.System.canWrite(applicationContext)) {
                val intent = Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS)
                intent.data = Uri.parse("package:$packageName")
                startActivityForResult(intent, 200)
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "expandNotis" -> {
                    NotificationExpander(this).expand()
                    result.success(null)
                }
                "changeLauncher" -> {
                    changeLauncher()
                    result.success(null)
                }
                "searchGoogle" -> {
                    val query = call.argument<String>("query")
                    if (query != null) {
                        searchGoogle(query)
                        result.success(null)
                    } else {
                        result.error("MISSING_ARGUMENT", "Query parameter is missing", null)
                    }
                }
                else -> {
                    result.notImplemented()
                    Log.d(TAG, "Error: No method found for ${call.method}!")
                }
            }
        }
    }

    private fun changeLauncher() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val intent = Intent(Settings.ACTION_HOME_SETTINGS)
            startActivity(intent)
        } else {
            val intent = Intent(Settings.ACTION_SETTINGS)
            startActivity(intent)
        }
    }

    private fun searchGoogle(query: String) {
        try {
            val intent = Intent(Intent.ACTION_WEB_SEARCH)
            intent.putExtra(SearchManager.QUERY, query)
            intent.setPackage("com.google.android.googlequicksearchbox")
            startActivity(intent)
        } catch (e: Exception) {
            // Log an error
        }
    }
}