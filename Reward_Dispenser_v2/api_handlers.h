#pragma once
#include <WebServer.h>

// ─── Tick (called every loop) ─────────────────────────────────────────────────
// Handles stepper movement between states. Called from web_server.cpp.

void APIHandlers_tick();

// ─── API Handlers ─────────────────────────────────────────────────────────────
// To add a new endpoint:
//   1. Declare it here
//   2. Implement it in api_handlers.cpp
//   3. Register it in web_server.cpp → registerAPIRoutes()

namespace APIHandlers {
  bool getHelloWorldInProgress();

  void dispense(WebServer& server);
  void helloWorld(WebServer& server);
  void timerStatus(WebServer& server);
  void timerStart(WebServer& server);
  void wifiConnect(WebServer& server);
  void wifiForget(WebServer& server);
  void wifiScan(WebServer& server);
  void status(WebServer& server);

} // namespace APIHandlers