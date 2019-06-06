package com.tekartik.tekartik_app_flutter_plugin;

import android.content.Context;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * TekartikAppFlutterPlugin
 */
public class TekartikAppFlutterPlugin implements MethodCallHandler {
    private final Context context;

    public TekartikAppFlutterPlugin(Context context) {
        this.context = context;
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "tekartik_app_flutter_plugin");
        channel.setMethodCallHandler(new TekartikAppFlutterPlugin(registrar.context()));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("isMonkeyRunning")) {
            result.success(MonkeyUtils.isRunning(context));
        } else {
            result.notImplemented();
        }
    }
}
