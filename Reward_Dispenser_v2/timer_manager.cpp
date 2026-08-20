// #include "config.h"
#include <Arduino.h>

// #include "neopixel_manager.h"
// using NeopixelManager::pixels;


namespace TimerManager {
    static unsigned long _timerEndAt    = 0;

//   static Message _currentMessage = Message::NONE;
//   unsigned long timer_end;

//   void begin() {
//   }

  void startTimer() {
    _timerEndAt      = millis() + 4000;
  }
//   void pauseTimer();
//   void resumeTimer();
//   void cancelTimer();

  int getTimerInProgress() { return _timerEndAt > 0; }
  int getTimerSecondsRemaining() { return  _timerEndAt - millis(); }

  void tick() {
    if (getTimerInProgress() && getTimerSecondsRemaining() <= 0) {
        _timerEndAt = 0;


        Serial.println("[Timer] Timer is complete");

        //do something to dispense
    }
  }
}