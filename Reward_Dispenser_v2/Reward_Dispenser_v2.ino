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
#include <ESPmDNS.h>
#include "config.h"
#include "wifi_manager.h"
#include "web_server.h"

#include "neopixel_manager.h"
using NeopixelManager::pixels;

#include "stepper_manager.h"
using StepperManager::stepper;

#include "api_handlers.h"


void setup() {
  Serial.begin(115200);
  delay(200);
  Serial.printf("\n\n=== %s v%s ===\n", DEVICE_NAME, FIRMWARE_VERSION);

  NeopixelManager::begin();
  // NeopixelManager::show_startup_started();

  NeopixelManager::setMessage(NeopixelManager::Message::STARTING_UP);

  StepperManager::begin();


  // ── Wi-Fi ──────────────────────────────────────────────────────────────────
  NeopixelManager::setMessage(NeopixelManager::Message::WIFI_CONNECTING);
  bool connected = WiFiManager::connectFromNVS();
  if (!connected) {
    WiFiManager::startAP();
  }

  MDNS.begin(DEVICE_NAME); // mDNS - allows device to be reached at http://DEVICE_NAME.local

  // NeopixelManager::show_wifi_success();
  NeopixelManager::setMessage(NeopixelManager::Message::WIFI_CONNECTED);

  // ── HTTP server ────────────────────────────────────────────────────────────
  WebServerManager::begin();

  // NeopixelManager::show_webserver_success();
  NeopixelManager::setMessage(NeopixelManager::Message::NONE);

  Serial.println("[Main] Setup complete. Entering loop.");
}

void loop() {
  WebServerManager::tick();   // handles HTTP requests + deferred GPIO tasks


  // switch (_dispenseState) {
  //   case DispenseState::IDLE:
  //   case DispenseState::MOVING_TO_POS1:
  //   case DispenseState::MOVING_TO_POS2:
  //     break;
  // }

  if (APIHandlers::getDispenseState() == DispenseState::IDLE) {
  // if (_currentMessage != NeopixelManager::Message::DISPENSING) {  
    if (WiFiManager::isConnected()) {
      NeopixelManager::setMessage(NeopixelManager::Message::WIFI_CONNECTED);
    } else {
      NeopixelManager::setMessage(NeopixelManager::Message::WIFI_DISCONNECTED);
    }
  }
  NeopixelManager::tick();

    // unsigned long current_millis = millis();
    // pixels.setPixelColor(0, pixels.ColorHSV(64436 * ((current_millis/5 - 0*30) % 360) / 360, 255, 255));
    // pixels.setPixelColor(1, pixels.ColorHSV(64436 * ((current_millis/5 - 1*30) % 360) / 360, 255, 255));
    // pixels.setPixelColor(2, pixels.ColorHSV(64436 * ((current_millis/5 - 2*30) % 360) / 360, 255, 255));


    // // _pixels.fill(_pixels.gamma32(_pixels.ColorHSV(hue, sat, val)));

    // pixels.show();
}
