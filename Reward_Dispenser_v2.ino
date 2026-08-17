// ─── SmartDevice Firmware ─────────────────────────────────────────────────────
// ESP32-C3 · Arduino framework
//
// Boot sequence:
//   1. Try to connect using saved Wi-Fi credentials (NVS)
//   2a. Success → start HTTP server (main UI + API)
//   2b. Failure → start AP hotspot → start HTTP server (setup UI)
//
// Adding a new API endpoint:
//   1. Declare handler in api_handlers.h
//   2. Implement handler in api_handlers.cpp
//   3. Register route in web_server.cpp → registerAPIRoutes()
//
// Dependencies (install via Arduino Library Manager or platformio.ini):
//   - WebServer     (built into esp32 Arduino core)
//   - Preferences   (built into esp32 Arduino core)
//   - ArduinoJson   >= 7.x  (by Benoit Blanchon)

#include <Arduino.h>
#include "config.h"
#include "wifi_manager.h"
#include "web_server.h"

#include "neopixel_manager.h"
using NeopixelManager::pixels;

#include "stepper_manager.h"
using StepperManager::stepper;


void setup() {
  Serial.begin(115200);
  delay(200);
  Serial.printf("\n\n=== %s v%s ===\n", DEVICE_NAME, FIRMWARE_VERSION);

  NeopixelManager::begin();
  StepperManager::begin();

  // ── Wi-Fi ──────────────────────────────────────────────────────────────────
  bool connected = WiFiManager::connectFromNVS();
  if (!connected) {
    WiFiManager::startAP();
  }

  // ── HTTP server ────────────────────────────────────────────────────────────
  WebServerManager::begin();

  Serial.println("[Main] Setup complete. Entering loop.");
}

void loop() {
  WebServerManager::tick();   // handles HTTP requests + deferred GPIO tasks

  if(WiFiManager::isConnected()) {
    pixels.fill(pixels.ColorHSV(64436 * 120 / 360, 255, 255));  //Green
    pixels.show();
  } else {
    pixels.fill(pixels.ColorHSV(0, 0, 255));  //White
    pixels.show();
  }

    // unsigned long current_millis = millis();
    // pixels.setPixelColor(0, pixels.ColorHSV(64436 * ((current_millis/5 - 0*30) % 360) / 360, 255, 255));
    // pixels.setPixelColor(1, pixels.ColorHSV(64436 * ((current_millis/5 - 1*30) % 360) / 360, 255, 255));
    // pixels.setPixelColor(2, pixels.ColorHSV(64436 * ((current_millis/5 - 2*30) % 360) / 360, 255, 255));


    // // _pixels.fill(_pixels.gamma32(_pixels.ColorHSV(hue, sat, val)));

    // pixels.show();
}
