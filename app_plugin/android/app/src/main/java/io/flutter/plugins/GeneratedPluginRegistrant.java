package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import com.tekartik.tekartik_app_flutter_plugin.TekartikAppFlutterPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    TekartikAppFlutterPlugin.registerWith(registry.registrarFor("com.tekartik.tekartik_app_flutter_plugin.TekartikAppFlutterPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
