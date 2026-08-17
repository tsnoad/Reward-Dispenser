#include "wifi_manager.h"
#include "config.h"

#include <WiFi.h>
#include <Preferences.h>

namespace WiFiManager {

// ─── Internal helpers ─────────────────────────────────────────────────────────

static Preferences _prefs;

// ─── Public API ───────────────────────────────────────────────────────────────

void startAP() {
  Serial.println("[WiFi] Starting AP: " AP_SSID);
  WiFi.mode(WIFI_AP);
  WiFi.softAP(AP_SSID, strlen(AP_PASSWORD) > 0 ? AP_PASSWORD : nullptr);
  Serial.print("[WiFi] AP IP: ");
  Serial.println(WiFi.softAPIP());
}

bool connectFromNVS() {
  String ssid, pass;
  if (!loadCredentials(ssid, pass)) {
    Serial.println("[WiFi] No credentials stored.");
    return false;
  }

  Serial.printf("[WiFi] Connecting to: %s\n", ssid.c_str());
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid.c_str(), pass.c_str());

  unsigned long start = millis();
  while (WiFi.status() != WL_CONNECTED) {
    if (millis() - start > WIFI_CONNECT_TIMEOUT_MS) {
      Serial.println("[WiFi] Connection timed out.");
      return false;
    }
    delay(250);
    Serial.print(".");
  }

  Serial.printf("\n[WiFi] Connected. IP: %s\n", WiFi.localIP().toString().c_str());
  return true;
}

void saveCredentials(const String& ssid, const String& password) {
  _prefs.begin(NVS_NAMESPACE, false);
  _prefs.putString(NVS_KEY_SSID, ssid);
  _prefs.putString(NVS_KEY_PASS, password);
  _prefs.end();
  Serial.printf("[WiFi] Credentials saved for SSID: %s\n", ssid.c_str());
}

bool loadCredentials(String& ssid, String& password) {
  _prefs.begin(NVS_NAMESPACE, true);
  ssid     = _prefs.getString(NVS_KEY_SSID, "");
  password = _prefs.getString(NVS_KEY_PASS, "");
  _prefs.end();
  return ssid.length() > 0;
}

void clearCredentials() {
  _prefs.begin(NVS_NAMESPACE, false);
  _prefs.remove(NVS_KEY_SSID);
  _prefs.remove(NVS_KEY_PASS);
  _prefs.end();
  Serial.println("[WiFi] Credentials cleared.");
}

bool isConnected() {
  return WiFi.status() == WL_CONNECTED;
}

String scanNetworksJSON() {
  int count = WiFi.scanNetworks();
  String json = "[";
  for (int i = 0; i < count; i++) {
    if (i > 0) json += ",";
    json += "{\"ssid\":\"" + WiFi.SSID(i) + "\","
            "\"rssi\":"   + String(WiFi.RSSI(i)) + ","
            "\"open\":"   + String(WiFi.encryptionType(i) == WIFI_AUTH_OPEN ? "true" : "false") + "}";
  }
  json += "]";
  WiFi.scanDelete();
  return json;
}

} // namespace WiFiManager
