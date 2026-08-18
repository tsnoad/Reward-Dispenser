#include "neopixel_manager.h"
#include "config.h"  // define PIN_NEOPIXEL and NEOPIXEL_COUNT here

#include "stepper_manager.h"
using StepperManager::stepper;

namespace NeopixelManager {
  Adafruit_NeoPixel pixels(NEOPIXEL_COUNT, PIN_NEOPIXEL, NEO_GRB + NEO_KHZ800);

  static Message _currentMessage = Message::NONE;

  void show_startup_started() {
    pixels.fill(pixels.Color(255, 255, 255));  //White
    pixels.show();
  }
  void show_wifi_success() {
    pixels.setPixelColor(0,pixels.Color(0, 255, 0));  //Green
    pixels.setPixelColor(1,pixels.Color(255, 255, 255));  //White
    pixels.setPixelColor(2,pixels.Color(255, 255, 255));  //White
    pixels.show();
  }
  void show_webserver_success() {
    pixels.setPixelColor(0,pixels.Color(0, 255, 0));  //Green
    pixels.setPixelColor(1,pixels.Color(0, 255, 0));  //Green
    pixels.setPixelColor(2,pixels.Color(255, 255, 255));  //White
    pixels.show();
  }

  void begin() {
    pixels.begin();
    pixels.show();
  }

  void setMessage(Message message) {
    if (message == _currentMessage) return;
    _currentMessage = message;

    switch (message) {
      case Message::STARTING_UP:
        pixels.fill(pixels.Color(50, 50, 0));       // dim yellow
        break;
      case Message::WIFI_CONNECTING:
        pixels.fill(pixels.Color(0, 0, 50));         // dim blue
        break;
      case Message::WIFI_CONNECTED:
        pixels.fill(pixels.Color(0, 50, 0));         // dim green
        break;
      case Message::WIFI_AP_MODE:
        pixels.fill(pixels.Color(0, 0, 50));         // dim blue
        break;
      case Message::WIFI_DISCONNECTED:
        pixels.fill(pixels.Color(50, 0, 0));         // dim red
        break;
      case Message::DISPENSING:
        pixels.fill(pixels.Color(50, 25, 0));        // dim orange
        break;
      case Message::NONE:
        pixels.fill(pixels.Color(0, 0, 0));          // off
        break;
    }

    pixels.show();
  }
  
  Message getMessage() { return _currentMessage; }
  
  void tick() {
    static uint32_t _lastTick = 0;
    uint32_t now = millis();
    if (now - _lastTick < NEOPIXEL_TICK_MS) return;
    _lastTick = now;

    switch (_currentMessage) {
      case Message::NONE:              Serial.println("[Neopixel] NONE");              break;
      case Message::STARTING_UP:       Serial.println("[Neopixel] STARTING_UP");       break;
      case Message::WIFI_CONNECTING:   Serial.println("[Neopixel] WIFI_CONNECTING");   break;
      case Message::WIFI_CONNECTED:    Serial.println("[Neopixel] WIFI_CONNECTED");    break;
      case Message::WIFI_AP_MODE:      Serial.println("[Neopixel] WIFI_AP_MODE");      break;
      case Message::WIFI_DISCONNECTED: Serial.println("[Neopixel] WIFI_DISCONNECTED"); break;
      case Message::DISPENSING:        Serial.println("[Neopixel] DISPENSING");        break;
    }

    switch (_currentMessage) {
      case Message::DISPENSING:
        // pixels.fill(pixels.Color(50, 25, 0));        // dim orange
        break;
    }
  }
}
