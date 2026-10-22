package com.example.privacy_guard

import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.TextView

/**
 * User-started, screen-wide dimming overlay.
 *
 * This is a software tint only. It cannot create physical viewing-angle privacy.
 * No camera is used by this service.
 */
class PrivacyOverlayService : Service() {
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> stopOverlay()
            else -> showOverlay()
        }
        return START_NOT_STICKY
    }

    private fun showOverlay() {
        if (overlayView != null) return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !android.provider.Settings.canDrawOverlays(this)) {
            stopSelf()
            return
        }

        val manager = getSystemService(WINDOW_SERVICE) as WindowManager
        windowManager = manager

        val panel = android.widget.FrameLayout(this).apply {
            setBackgroundColor(0xB8071426.toInt())
            isClickable = false
            isFocusable = false
        }

        val label = TextView(this).apply {
            text = "PRIVACY GUARD  •  SCREEN SHIELDED"
            textSize = 13f
            setTextColor(0xFFFFFFFF.toInt())
            gravity = Gravity.CENTER
            setPadding(22, 14, 22, 14)
            background = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = 48f
                setColor(0xE617345F.toInt())
                setStroke(1, 0xFF55D6E8.toInt())
            }
        }
        val labelParams = android.widget.FrameLayout.LayoutParams(
            android.widget.FrameLayout.LayoutParams.WRAP_CONTENT,
            android.widget.FrameLayout.LayoutParams.WRAP_CONTENT,
            Gravity.TOP or Gravity.CENTER_HORIZONTAL
        ).apply {
            topMargin = (32 * resources.displayMetrics.density).toInt()
        }
        panel.addView(label, labelParams)

        val overlayType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            overlayType,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
        }

        try {
            manager.addView(panel, params)
            overlayView = panel
        } catch (_: Exception) {
            overlayView = null
            stopSelf()
        }
    }

    private fun stopOverlay() {
        overlayView?.let { view ->
            try {
                windowManager?.removeView(view)
            } catch (_: Exception) {
                // The window may already have been removed by the system.
            }
        }
        overlayView = null
        windowManager = null
        stopSelf()
    }

    override fun onDestroy() {
        stopOverlay()
        super.onDestroy()
    }

    companion object {
        const val ACTION_START = "com.example.privacy_guard.OVERLAY_START"
        const val ACTION_STOP = "com.example.privacy_guard.OVERLAY_STOP"
    }
}
