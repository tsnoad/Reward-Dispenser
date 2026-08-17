#pragma once

// ─── Web Server ───────────────────────────────────────────────────────────────
// Owns the WebServer instance. Registers all routes (HTML pages + API).
// Call begin() once, then tick() every loop iteration.

namespace WebServerManager {

  void begin();   // Register all routes and start listening
  void tick();    // Must be called from loop(); processes HTTP + GPIO tasks

} // namespace WebServerManager
