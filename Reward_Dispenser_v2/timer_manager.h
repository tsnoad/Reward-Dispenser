#pragma once

namespace TimerManager {
//   enum class Message {
//     NONE,
//     STARTING_UP,
//     WIFI_CONNECTING,
//     WEBSERVER_STARTING,
//     SETUP_COMPLETE,
//     WIFI_CONNECTED,
//     WIFI_AP_MODE,
//     WIFI_DISCONNECTED,
//     DISPENSING,
//     HELLOWORLD,
//   };

//   void begin();
  void startTimer();
//   void pauseTimer();
//   void resumeTimer();
//   void cancelTimer();

  int getTimerInProgress();
  int getTimerSecondsRemaining();

  void tick();

//   Message getMessage();
//   int phase_brightness(unsigned long current_millis, int period_ms, int phase_offset_ms, int brightness_max=255, int brightness_min=0);
}