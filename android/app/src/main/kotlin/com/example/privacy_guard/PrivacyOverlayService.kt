package com.example.privacy_guard

import android.app.Service
import android.content.Intent
import android.graphics.Canvas
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.PixelFormat
import android.graphics.Shader
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.TextView

/**
 * User-started, screen-wide side-shading overlay.
 *
 * This is only a software visual effect. It cannot create physical viewing-angle privacy.
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
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
            !android.provider.Settings.canDrawOverlays(this)
        ) {
            stopSelf()
            return
        }

        val manager = getSystemService(WINDOW_SERVICE) as WindowManager
        windowManager = manager

        val panel = FrameLayout(this).apply {
            setBackgroundColor(android.graphics.Color.TRANSPARENT)
            isClickable = false
            isFocusable = false
        }
        panel.addView(
            SidePrivacyTintView(this),
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        )

        val label = TextView(this).apply {
            text = "PRIVACY GUARD  •  SIDE SHADE ACTIVE"
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
        val labelParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.WRAP_CONTENT,
            FrameLayout.LayoutParams.WRAP_CONTENT,
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
        overlayView?.let { view ->
            try {
                windowManager?.removeView(view)
            } catch (_: Exception) {
                // The system may already have removed the overlay window.
            }
        }
        overlayView = null
        windowManager = null
        super.onDestroy()
    }

    private class SidePrivacyTintView(context: android.content.Context) : View(context) {
        private val paint = Paint(Paint.ANTI_ALIAS_FLAG)

        override fun onDraw(canvas: Canvas) {
            super.onDraw(canvas)
            if (width <= 0 || height <= 0) return

            paint.shader = LinearGradient(
                0f,
                0f,
                width.toFloat(),
                0f,
                intArrayOf(
                    0xF5071426.toInt(),
                    0xA5071426.toInt(),
                    0x18071426,
                    0xA5071426.toInt(),
                    0xF5071426.toInt()
                ),
                floatArrayOf(0f, 0.20f, 0.50f, 0.80f, 1f),
                Shader.TileMode.CLAMP
            )
            canvas.drawRect(0f, 0f, width.toFloat(), height.toFloat(), paint)
            paint.shader = null
        }
    }

    companion object {
        const val ACTION_START = "com.example.privacy_guard.OVERLAY_START"
        const val ACTION_STOP = "com.example.privacy_guard.OVERLAY_STOP"
    }
}
