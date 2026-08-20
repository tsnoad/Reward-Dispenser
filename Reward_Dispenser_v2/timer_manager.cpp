#include <Arduino.h>

namespace TimerManager {
  static unsigned long _timerEndAt    = 0;

  void startTimer(int durationMs) {
    _timerEndAt = millis() + durationMs;
  }
//   void pauseTimer();
//   void resumeTimer();
//   void cancelTimer();

  bool getTimerInProgress() { return _timerEndAt > 0; }
  int getTimerMsRemaining() { return  _timerEndAt - millis(); }

  void tick() {
    if (getTimerInProgress() && getTimerMsRemaining() <= 0) {
        _timerEndAt = 0;

        Serial.println("[Timer] Timer is complete");
    }
  }
}