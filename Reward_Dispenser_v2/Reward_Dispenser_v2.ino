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

#include "stepper_manager.h"
using StepperManager::stepper;

#include "timer_manager.h"

#include "neopixel_manager.h"
using NeopixelManager::pixels;


#include "api_handlers.h"


void setup() {
  Serial.begin(115200);
  delay(200);
  Serial.printf("\n\n=== %s v%s ===\n", DEVICE_NAME, FIRMWARE_VERSION);

  // ── Neopixel ───────────────────────────────────────────────────────────────
  NeopixelManager::begin();
  NeopixelManager::setMessage(NeopixelManager::Message::STARTING_UP);

  // ── Stepper -───────────────────────────────────────────────────────────────
  StepperManager::begin();

  // ── Wi-Fi ──────────────────────────────────────────────────────────────────
  NeopixelManager::setMessage(NeopixelManager::Message::WIFI_CONNECTING);

  bool connected = WiFiManager::connectFromNVS();
  if (!connected) {
    WiFiManager::startAP();
  }

  MDNS.begin(DEVICE_NAME); // mDNS - allows device to be reached at http://DEVICE_NAME.local

  // ── HTTP server ────────────────────────────────────────────────────────────
  NeopixelManager::setMessage(NeopixelManager::Message::WEBSERVER_STARTING);

  WebServerManager::begin();

  // NeopixelManager::show_webserver_success();
  NeopixelManager::setMessage(NeopixelManager::Message::SETUP_COMPLETE);

  Serial.println("[Main] Setup complete. Entering loop.");
}

void loop() {
  WebServerManager::tick();   // handles HTTP requests + deferred GPIO tasks
  TimerManager::tick();

  if (APIHandlers::getDispenseState() == DispenseState::IDLE && !APIHandlers::getHelloWorldInProgress() && !TimerManager::getTimerInProgress()) {
  // if (_currentMessage != NeopixelManager::Message::DISPENSING) {  
    if (!WiFiManager::isConnected()) {
      NeopixelManager::setMessage(NeopixelManager::Message::WIFI_DISCONNECTED);
    } else if (millis() < 10000) {
      NeopixelManager::setMessage(NeopixelManager::Message::WIFI_CONNECTED);
    } else {
      NeopixelManager::setMessage(NeopixelManager::Message::NONE);
    }
  }
  
  NeopixelManager::tick();
}
