package com.yourcompany.app;

import android.content.Context;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiManager;
import android.os.Build;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class WifiHandler implements FlutterPlugin, MethodCallHandler {
  private MethodChannel channel;
  private Context context;
  private WifiManager wifiManager;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    channel = new MethodChannel(binding.getBinaryMessenger(), "com.yourcompany.app/wifi");
    channel.setMethodCallHandler(this);
    context = binding.getApplicationContext();
    wifiManager = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "connectToWifi":
        String ssid = call.argument("ssid");
        String password = call.argument("password");
        connectToWifi(ssid, password, result);
        break;
      case "getWifiStatus":
        getWifiStatus(result);
        break;
      case "setWifiEnabled":
        boolean enabled = call.argument("enabled");
        setWifiEnabled(enabled, result);
        break;
      default:
        result.notImplemented();
    }
  }

  private void connectToWifi(String ssid, String password, Result result) {
    try {
      // Remove existing configuration for this network if it exists
      WifiConfiguration conf = new WifiConfiguration();
      conf.SSID = String.format("\"%s\"", ssid);
      conf.preSharedKey = String.format("\"%s\"", password);

      // For WPA networks
      conf.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.WPA_PSK);

      int netId = wifiManager.addNetwork(conf);
      wifiManager.disconnect();
      boolean success = wifiManager.enableNetwork(netId, true);
      wifiManager.reconnect();

      result.success(success);
    } catch (Exception e) {
      result.error("CONNECTION_FAILED", e.getMessage(), null);
    }
  }

  private void getWifiStatus(Result result) {
    try {
      String status;
      switch (wifiManager.getWifiState()) {
        case WifiManager.WIFI_STATE_ENABLED:
          status = "enabled";
          break;
        case WifiManager.WIFI_STATE_ENABLING:
          status = "enabling";
          break;
        case WifiManager.WIFI_STATE_DISABLED:
          status = "disabled";
          break;
        case WifiManager.WIFI_STATE_DISABLING:
          status = "disabling";
          break;
        default:
          status = "unknown";
      }
      result.success(status);
    } catch (Exception e) {
      result.error("STATUS_FAILED", e.getMessage(), null);
    }
  }

  private void setWifiEnabled(boolean enabled, Result result) {
    try {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        // On Android 10+, apps can't enable/disable WiFi directly
        result.success(false);
      } else {
        result.success(wifiManager.setWifiEnabled(enabled));
      }
    } catch (Exception e) {
      result.error("ENABLE_FAILED", e.getMessage(), null);
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}