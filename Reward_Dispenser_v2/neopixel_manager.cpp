#include "neopixel_manager.h"
#include "config.h"  // define PIN_NEOPIXEL and NEOPIXEL_COUNT here


namespace NeopixelManager {
  Adafruit_NeoPixel pixels(NEOPIXEL_COUNT, PIN_NEOPIXEL, NEO_GRB + NEO_KHZ800);

  void begin() {
    pixels.begin();
    pixels.show();
  }
}
