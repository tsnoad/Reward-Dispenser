#pragma once
#include <Adafruit_NeoPixel.h>

namespace NeopixelManager {
  extern Adafruit_NeoPixel pixels;

  enum class Message {
    NONE,
    STARTING_UP,
    WIFI_CONNECTING,
    WEBSERVER_STARTING,
    SETUP_COMPLETE,
    WIFI_CONNECTED,
    WIFI_AP_MODE,
    WIFI_DISCONNECTED,
    DISPENSING,
  };

  void begin();
  void setMessage(Message message);
  Message getMessage();
  void tick();

  int phase_brightness(unsigned long current_millis, int period_ms, int phase_offset_ms, int brightness_max=255, int brightness_min=0);
  
}