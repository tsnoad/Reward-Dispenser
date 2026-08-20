#include "neopixel_manager.h"
#include "config.h"

#include "stepper_manager.h"
using StepperManager::stepper;

namespace NeopixelManager {
  Adafruit_NeoPixel pixels(NEOPIXEL_COUNT, PIN_NEOPIXEL_DATA, NEO_GRB + NEO_KHZ800);

  static Message _currentMessage = Message::NONE;

  void begin() {
    pixels.begin();
    pixels.show();
  }

  void setMessage(Message message) {
    if (message == _currentMessage) return;
    _currentMessage = message;

    switch (message) {
      case Message::STARTING_UP:
        pixels.fill(pixels.Color(255, 255, 255));  //White
        break;
      case Message::WIFI_CONNECTING:
        pixels.setPixelColor(0,pixels.Color(0, 255, 0));  //Green
        pixels.setPixelColor(1,pixels.Color(255, 255, 255));  //White
        pixels.setPixelColor(2,pixels.Color(255, 255, 255));  //White
        break;
      case Message::WEBSERVER_STARTING:
        pixels.setPixelColor(0,pixels.Color(0, 255, 0));  //Green
        pixels.setPixelColor(1,pixels.Color(0, 255, 0));  //Green
        pixels.setPixelColor(2,pixels.Color(255, 255, 255));  //White
        break;
      // case Message::WIFI_CONNECTED:
      //   pixels.fill(pixels.Color(0, 50, 0));         // dim green
      //   break;
      case Message::SETUP_COMPLETE:
        pixels.fill(pixels.Color(0, 255, 0));  //Green
        break;
      case Message::WIFI_AP_MODE:
        pixels.fill(pixels.Color(0, 0, 50));         // dim blue
        break;
      case Message::WIFI_DISCONNECTED:
        pixels.fill(pixels.Color(50, 0, 0));         // dim red
        break;
      case Message::NONE:
        pixels.fill(pixels.Color(0, 0, 0));          // off
        break;
      // These messages are handled by the tick()
      // case Message::DISPENSING:
      // case Message::HELLOWORLD:
      //   break;
    }

    pixels.show();
  }
  
  Message getMessage() { return _currentMessage; }
  
  void tick() {
    static uint32_t _lastTick = 0;
    uint32_t now = millis();
    if (now - _lastTick < NEOPIXEL_TICK_MS) return;
    _lastTick = now;

    // switch (_currentMessage) {
    //   case Message::NONE:              Serial.println("[Neopixel] NONE");              break;
    //   case Message::STARTING_UP:       Serial.println("[Neopixel] STARTING_UP");       break;
    //   case Message::WIFI_CONNECTING:   Serial.println("[Neopixel] WIFI_CONNECTING");   break;
    //   case Message::WIFI_CONNECTED:    Serial.println("[Neopixel] WIFI_CONNECTED");    break;
    //   case Message::WIFI_AP_MODE:      Serial.println("[Neopixel] WIFI_AP_MODE");      break;
    //   case Message::WIFI_DISCONNECTED: Serial.println("[Neopixel] WIFI_DISCONNECTED"); break;
    //   case Message::DISPENSING:        Serial.println("[Neopixel] DISPENSING");        break;
    // }

    unsigned long current_millis = millis();

    switch (_currentMessage) {
      case Message::WIFI_CONNECTED:
      // Serial.println((sin((float)(current_millis % 1000)/1000*2*PI)+1)/2);
        pixels.setPixelColor(0, pixels.ColorHSV(64436 * 120 / 360, 255, phase_brightness(current_millis, 15000, 0*250, 127)));
        pixels.setPixelColor(1, pixels.ColorHSV(64436 * 120 / 360, 255, phase_brightness(current_millis, 15000, 1*250, 127)));
        pixels.setPixelColor(2, pixels.ColorHSV(64436 * 120 / 360, 255, phase_brightness(current_millis, 15000, 2*250, 127)));
        // pixels.setPixelColor(2, pixels.ColorHSV(64436 * 120 / 360, 255, ((((float)sin(Math.deg2rad((current_millis + 2*100 % 1000)/1000*360))/2)+1)*255)));
        pixels.show();
        break;
      case Message::DISPENSING:
        pixels.setPixelColor(0, pixels.ColorHSV(64436 * ((current_millis/5 - 0*30) % 360) / 360, 255, 255));
        pixels.setPixelColor(1, pixels.ColorHSV(64436 * ((current_millis/5 - 1*30) % 360) / 360, 255, 255));
        pixels.setPixelColor(2, pixels.ColorHSV(64436 * ((current_millis/5 - 2*30) % 360) / 360, 255, 255));
        // _pixels.fill(_pixels.gamma32(_pixels.ColorHSV(hue, sat, val)));
        pixels.show();
        break;
      case Message::HELLOWORLD:
        pixels.setPixelColor(0, pixels.ColorHSV(64436 * 120 / 360, 255, phase_brightness(current_millis, 1000, 0*100, 255, 31)));
        pixels.setPixelColor(1, pixels.ColorHSV(64436 * 120 / 360, 255, phase_brightness(current_millis, 1000, 1*100, 255, 31)));
        pixels.setPixelColor(2, pixels.ColorHSV(64436 * 120 / 360, 255, phase_brightness(current_millis, 1000, 2*100, 255, 31)));
        pixels.show();
        break;
      case Message::TIMER_IN_PROGRESS:
        pixels.setPixelColor(0, pixels.ColorHSV(64436 * ((current_millis/5 - 0*30) % 360) / 360, 255, 255));
        pixels.setPixelColor(1, pixels.ColorHSV(64436 * ((current_millis/5 - 1*30) % 360) / 360, 255, 255));
        pixels.setPixelColor(2, pixels.ColorHSV(64436 * ((current_millis/5 - 2*30) % 360) / 360, 255, 255));
        pixels.show();
        break;
    }
  }

  int phase_brightness(unsigned long current_millis, int period_ms, int phase_offset_ms, int brightness_max, int brightness_min) {
    return (brightness_max-brightness_min)*(sin((float)(current_millis - phase_offset_ms % period_ms)/period_ms*2*PI)+1)/2+brightness_min;
  }
}
