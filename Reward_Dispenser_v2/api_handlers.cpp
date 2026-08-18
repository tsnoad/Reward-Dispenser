#include "api_handlers.h"
#include "wifi_manager.h"

#include "config.h"

#include <Arduino.h>
#include <ArduinoJson.h>
#include <WiFi.h>


#include "neopixel_manager.h"
using NeopixelManager::pixels;

#include "stepper_manager.h"
using StepperManager::stepper;

// ─── State ────────────────────────────────────────────────────────────────────

static DispenseState _dispenseState = DispenseState::IDLE;

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
  switch (_dispenseState) {

    case DispenseState::IDLE:
      break;

    case DispenseState::MOVING_TO_POS1:
      if (!stepper.motionComplete()) {
        Serial.println(stepper.getCurrentPositionInRevolutions());
        stepper.processMovement();

        // unsigned long current_millis = millis();
        // pixels.setPixelColor(0, pixels.ColorHSV(64436 * ((current_millis/5 - 0*30) % 360) / 360, 255, 255));
        // pixels.setPixelColor(1, pixels.ColorHSV(64436 * ((current_millis/5 - 1*30) % 360) / 360, 255, 255));
        // pixels.setPixelColor(2, pixels.ColorHSV(64436 * ((current_millis/5 - 2*30) % 360) / 360, 255, 255));
        // pixels.show();
      } else {
        stepper.setupMoveInRevolutions(stepper.getCurrentPositionInRevolutions() - revolutions_to_standby_position);
        _dispenseState = DispenseState::MOVING_TO_POS2;
      }
      break;

    case DispenseState::MOVING_TO_POS2:
      if (!stepper.motionComplete()) {
        Serial.println(stepper.getCurrentPositionInRevolutions());
        stepper.processMovement();

        // unsigned long current_millis = millis();
        // pixels.setPixelColor(0, pixels.ColorHSV(64436 * ((current_millis/5 - 0*30) % 360) / 360, 255, 255));
        // pixels.setPixelColor(1, pixels.ColorHSV(64436 * ((current_millis/5 - 1*30) % 360) / 360, 255, 255));
        // pixels.setPixelColor(2, pixels.ColorHSV(64436 * ((current_millis/5 - 2*30) % 360) / 360, 255, 255));
        // pixels.show();
        
      } else {
        //were done, disable the stepper
        digitalWrite(MOTOR_ENABLE_PIN, HIGH);

        // pixels.fill(pixels.ColorHSV(64436 * 120 / 360, 255, 255));  //Green
        // pixels.show();

        _dispenseState = DispenseState::IDLE;


        NeopixelManager::setMessage(NeopixelManager::Message::NONE);
      }
      break;
  }
}

// ─── Handlers ─────────────────────────────────────────────────────────────────

namespace APIHandlers {

  DispenseState getDispenseState() { return _dispenseState; }

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