#pragma once
#include <Arduino.h>

// ─── WiFi Manager ─────────────────────────────────────────────────────────────
// Handles AP mode for first-time setup and STA mode for normal operation.
// Credentials are persisted to NVS (non-volatile storage).

namespace WiFiManager {

  // Start AP hotspot for setup; returns when client submits credentials
  // or permanently (loop is driven from web server callbacks).
  void startAP();

  // Attempt to connect using stored credentials.
  // Returns true if connection succeeds within WIFI_CONNECT_TIMEOUT_MS.
  bool connectFromNVS();

  // Save credentials to NVS.
  void saveCredentials(const String& ssid, const String& password);

  // Load credentials from NVS. Returns false if none stored.
  bool loadCredentials(String& ssid, String& password);

  // Clear stored credentials (triggers AP mode on next boot).
  void clearCredentials();

  // Returns true if currently connected to a STA network.
  bool isConnected();

  // Scan for nearby networks; returns JSON array string.
  String scanNetworksJSON();

} // namespace WiFiManager
