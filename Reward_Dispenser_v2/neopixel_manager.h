#pragma once
#include <Adafruit_NeoPixel.h>

namespace NeopixelManager {
  extern Adafruit_NeoPixel pixels;

  enum class Message {
    NONE,
    STARTING_UP,
    WIFI_CONNECTING,
    WIFI_CONNECTED,
    WIFI_AP_MODE,
    WIFI_DISCONNECTED,
    DISPENSING,
  };
  

  void show_startup_started();
  void show_wifi_success();
  void show_webserver_success();

  void begin();
  void setMessage(Message message);
  Message getMessage();
  void tick();
  
}