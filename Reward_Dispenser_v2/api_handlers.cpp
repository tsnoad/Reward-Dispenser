#include "api_handlers.h"
#include "wifi_manager.h"

#include "config.h"

#include <Arduino.h>
#include <ArduinoJson.h>
#include <WiFi.h>

#include "stepper_manager.h"
using StepperManager::stepper;

#include "timer_manager.h"

#include "neopixel_manager.h"
using NeopixelManager::pixels;

// ─── State ────────────────────────────────────────────────────────────────────

static DispenseState _dispenseState = DispenseState::IDLE;

static bool _helloWorldInProgress   = false;
static uint32_t _helloWorldEndAt    = 0;

// ─── Internal helpers ─────────────────────────────────────────────────────────

static void sendJSON(WebServer& server, int code, const String& body) {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(code, "application/json", body);
}

static bool parseBody(WebServer& server, JsonDocument& doc) {
  if (!server.hasArg("plain") || server.arg("plain").isEmpty()) {
    sendJSON(server, 400, R"({"ok":false,"error":"Empty body"})");
    return false;
  }
  DeserializationError err = deserializeJson(doc, server.arg("plain"));
  if (err) {
    sendJSON(server, 400, R"({"ok":false,"error":"Invalid JSON"})");
    return false;
  }
  return true;
}

// ─── Tick (called every loop) ─────────────────────────────────────────────────

void APIHandlers_tick() {
  if (_helloWorldInProgress && millis() >= _helloWorldEndAt) {
    _helloWorldInProgress = false;

    if(NeopixelManager::getMessage() == NeopixelManager::Message::HELLOWORLD) NeopixelManager::setMessage(NeopixelManager::Message::NONE);

    Serial.println("[API] Hello World complete.");
  }

  switch (_dispenseState) {
    case DispenseState::IDLE:
      break;

    case DispenseState::MOVING_TO_POS1:
      if (!stepper.motionComplete()) {
        // Serial.println(stepper.getCurrentPositionInRevolutions());
        stepper.processMovement();
      } else {
        stepper.setupMoveInRevolutions(stepper.getCurrentPositionInRevolutions() - revolutions_to_standby_position);
        _dispenseState = DispenseState::MOVING_TO_POS2;
      }
      break;

    case DispenseState::MOVING_TO_POS2:
      if (!stepper.motionComplete()) {
        // Serial.println(stepper.getCurrentPositionInRevolutions());
        stepper.processMovement();
        
      } else {
        //were done, disable the stepper
        digitalWrite(MOTOR_ENABLE_PIN, HIGH);

        _dispenseState = DispenseState::IDLE;

        if(NeopixelManager::getMessage() == NeopixelManager::Message::DISPENSING) NeopixelManager::setMessage(NeopixelManager::Message::NONE);

        Serial.println("[API] Dispense complete.");
      }
      break;
  }
}

// ─── Handlers ─────────────────────────────────────────────────────────────────

namespace APIHandlers {
  DispenseState getDispenseState() { return _dispenseState; }
  bool getHelloWorldInProgress() { return _helloWorldInProgress; }

  void dispense(WebServer& server) {
    Serial.println("[API] POST /api/dispense");

    if (_dispenseState != DispenseState::IDLE) {
      sendJSON(server, 409, R"({"ok":false,"error":"Dispense already in progress"})");
      return;
    }

    //enable the stepper
    digitalWrite(MOTOR_ENABLE_PIN, LOW);

    stepper.setupMoveInRevolutions(stepper.getCurrentPositionInRevolutions() - revolutions_to_feed_position);
    _dispenseState = DispenseState::MOVING_TO_POS1;

    NeopixelManager::setMessage(NeopixelManager::Message::DISPENSING);

    sendJSON(server, 200, R"({"ok":true,"message":"Dispensing"})");
  }

  void helloWorld(WebServer& server) {
    Serial.println("[API] POST /api/helloworld");

    if (_helloWorldInProgress) {
      sendJSON(server, 409, R"({"ok":false,"error":"Hello World already in progress"})");
      return;
    }

    _helloWorldInProgress = true;
    _helloWorldEndAt      = millis() + 4000;

    NeopixelManager::setMessage(NeopixelManager::Message::HELLOWORLD);

    sendJSON(server, 200, R"({"ok":true,"message":"Hello World!"})");
  }

  void timerStart(WebServer& server) {
    Serial.println("[API] POST /api/timer/start");

    if (TimerManager::getTimerInProgress()) {
      sendJSON(server, 409, R"({"ok":false,"error":"Timer already in progress"})");
      return;
    }

    TimerManager::startTimer();

    NeopixelManager::setMessage(NeopixelManager::Message::TIMER_IN_PROGRESS);

    sendJSON(server, 200, R"({"ok":true,"message":"Timer Started"})");
  }

  void wifiConnect(WebServer& server) {
    Serial.println("[API] POST /api/wifi/connect");

    JsonDocument doc;
    if (!parseBody(server, doc)) return;

    String ssid = doc["ssid"] | "";
    String pass = doc["password"] | "";

    if (ssid.isEmpty()) {
      sendJSON(server, 400, R"({"ok":false,"error":"ssid required"})");
      return;
    }

    WiFiManager::saveCredentials(ssid, pass);
    sendJSON(server, 200, R"({"ok":true,"message":"Saved. Rebooting…"})");

    delay(500);
    ESP.restart();
  }

  void wifiForget(WebServer& server) {
    Serial.println("[API] POST /api/wifi/forget");
    WiFiManager::clearCredentials();
    sendJSON(server, 200, R"({"ok":true,"message":"Credentials cleared. Rebooting…"})");
    delay(500);
    ESP.restart();
  }

  void wifiScan(WebServer& server) {
    Serial.println("[API] GET /api/wifi/scan");
    String networks = WiFiManager::scanNetworksJSON();
    sendJSON(server, 200, "{\"ok\":true,\"networks\":" + networks + "}");
  }

  void status(WebServer& server) {
    Serial.println("[API] GET /api/status");
    String ssid, pass;
    WiFiManager::loadCredentials(ssid, pass);

    JsonDocument doc;
    doc["ok"]                = true;
    doc["device"]            = DEVICE_NAME;
    doc["firmware"]          = FIRMWARE_VERSION;
    doc["wifi"]["connected"] = WiFiManager::isConnected();
    doc["wifi"]["ip"]        = WiFi.localIP().toString();
    doc["wifi"]["ssid"]      = ssid;
    doc["uptime_ms"]         = millis();

    String out;
    serializeJson(doc, out);
    sendJSON(server, 200, out);
  }

} // namespace APIHandlers