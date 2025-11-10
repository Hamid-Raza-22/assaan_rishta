package com.asan.rishta.matrimonial.asan_rishta

import android.content.ActivityNotFoundException
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val DEVELOPER_MODE_CHANNEL = "com.asaanrishta.app/developer_mode"
    private val SCREEN_SECURITY_CHANNEL = "com.asaanrishta.app/screen_security"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Developer Mode Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEVELOPER_MODE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isDeveloperModeEnabled" -> {
                    val isDeveloperMode = checkDeveloperMode()
                    result.success(isDeveloperMode)
                }
                "openDeveloperSettings" -> {
                    openDeveloperSettings()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Screen Security Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SCREEN_SECURITY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableScreenSecurity" -> {
                    enableScreenSecurity()
                    result.success(true)
                }
                "disableScreenSecurity" -> {
                    disableScreenSecurity()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    /**
     * Enable screen security - Blocks screenshots and screen recording
     */
    private fun enableScreenSecurity() {
        window?.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
    }
    
    /**
     * Disable screen security - Allows screenshots and screen recording
     */
    private fun disableScreenSecurity() {
        window?.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }

    /**
     * Check if developer mode / USB debugging is enabled
     */
    private fun checkDeveloperMode(): Boolean {
        return try {
            // Check if USB debugging is enabled
            val adbEnabled = Settings.Global.getInt(
                contentResolver,
                Settings.Global.ADB_ENABLED,
                0
            ) == 1
            
            adbEnabled
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Open device developer settings
     * Handles Android 10 and below properly
     */
    private fun openDeveloperSettings() {
        try {
            // Try opening developer settings directly
            val intent = Intent(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            startActivity(intent)
        } catch (e: ActivityNotFoundException) {
            // Developer settings not available, try alternative methods
            try {
                // For some devices, especially Android 10 and below
                // Try to open device info settings where developer options can be accessed
                val intent = Intent(Settings.ACTION_DEVICE_INFO_SETTINGS)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                startActivity(intent)
            } catch (ex: ActivityNotFoundException) {
                // Last fallback - open main settings
                try {
                    val intent = Intent(Settings.ACTION_SETTINGS)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    startActivity(intent)
                } catch (ex2: Exception) {
                    ex2.printStackTrace()
                }
            } catch (ex: Exception) {
                // Generic fallback to main settings
                try {
                    val intent = Intent(Settings.ACTION_SETTINGS)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    startActivity(intent)
                } catch (ex2: Exception) {
                    ex2.printStackTrace()
                }
            }
        } catch (e: Exception) {
            // Generic exception handling
            e.printStackTrace()
            try {
                val intent = Intent(Settings.ACTION_SETTINGS)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                startActivity(intent)
            } catch (ex: Exception) {
                ex.printStackTrace()
            }
        }
    }
}
