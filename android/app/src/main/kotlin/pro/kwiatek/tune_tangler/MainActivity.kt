package pro.kwiatek.tune_tangler

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Draw behind system bars; Flutter applies MediaQuery insets for layout.
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
    }

    companion object {
        private const val CHANNEL = "pro.kwiatek.tune_tangler/screenshot"
        private const val ACTION = "pro.kwiatek.tune_tangler.SCREENSHOT_CMD"
    }

    private var methodChannel: MethodChannel? = null
    private var receiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val cmd = intent?.getStringExtra("cmd") ?: return
                val args = HashMap<String, Any?>()
                intent.extras?.keySet()?.forEach { key ->
                    if (key != "cmd") args[key] = intent.getStringExtra(key)
                }
                runOnUiThread {
                    methodChannel?.invokeMethod(cmd, args)
                }
            }
        }

        val filter = IntentFilter(ACTION)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(receiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            registerReceiver(receiver, filter)
        }
    }

    override fun onDestroy() {
        receiver?.let { unregisterReceiver(it) }
        super.onDestroy()
    }
}
