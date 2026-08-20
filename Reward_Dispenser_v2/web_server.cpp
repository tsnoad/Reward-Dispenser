#include "web_server.h"
#include "api_handlers.h"
#include "wifi_manager.h"
#include "config.h"

#include <WebServer.h>

// ─── Forward declaration for GPIO tick ────────────────────────────────────────
extern void APIHandlers_tick();

// ─── Server instance ──────────────────────────────────────────────────────────
static WebServer _server(HTTP_PORT);

// ─── HTML Pages ───────────────────────────────────────────────────────────────
// Each page is a raw string stored in flash (PROGMEM) to save RAM.
// Tip: For very large UIs, move these to LittleFS files in /data.

// Shared CSS & JS injected into every page via F() macro
static const char HTML_HEAD[] PROGMEM = R"rawhtml(
<!DOCTYPE html><html lang="en"><head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>)rawhtml";

static const char HTML_STYLE[] PROGMEM = R"rawhtml(</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500&family=DM+Mono:wght@400;500&display=swap" rel="stylesheet">
<style>
  :root {
    --bg:        #0f0f11;
    --surface:   #18181c;
    --surface2:  #222228;
    --border:    #2e2e38;
    --accent:    #e8a04a;
    --accent2:   #c97c2a;
    --text:      #e8e8ec;
    --muted:     #7a7a8c;
    --success:   #4ade80;
    --error:     #f87171;
    --radius:    14px;
    --radius-sm: 8px;
  }
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
  html { height: 100%; }
  body {
    font-family: 'DM Sans', sans-serif;
    background: var(--bg);
    color: var(--text);
    min-height: 100%;
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 24px 16px 48px;
  }
  .wordmark {
    font-size: 13px;
    font-weight: 500;
    letter-spacing: 0.18em;
    text-transform: uppercase;
    color: var(--accent);
    margin-bottom: 40px;
    display: flex;
    align-items: center;
    gap: 8px;
  }
  .wordmark svg { opacity: 0.9; }
  .card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    padding: 28px 24px;
    width: 100%;
    max-width: 420px;
    margin-bottom: 16px;
  }
  .card-title {
    font-size: 11px;
    font-weight: 500;
    letter-spacing: 0.15em;
    text-transform: uppercase;
    color: var(--muted);
    margin-bottom: 20px;
  }
  h1 { font-size: 22px; font-weight: 400; margin-bottom: 8px; }
  p  { font-size: 14px; color: var(--muted); line-height: 1.6; }
  label {
    display: block;
    font-size: 12px;
    font-weight: 500;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: var(--muted);
    margin-bottom: 8px;
  }
  input[type=text], input[type=password], select {
    width: 100%;
    background: var(--surface2);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    color: var(--text);
    font-family: inherit;
    font-size: 15px;
    padding: 12px 14px;
    outline: none;
    transition: border-color 0.2s;
    margin-bottom: 16px;
    appearance: none;
  }
  input:focus, select:focus { border-color: var(--accent); }
  .timer-face {
    display: flex;
    flex-direction: column;
    align-items: center;
    margin: 8px 0 24px;
  }
  .timer-ring {
    width: 160px;
    height: 160px;
    border-radius: 50%;
    border: 2px solid var(--border);
    background: var(--surface2);
    box-shadow: inset 0 2px 12px rgba(0,0,0,0.4), 0 0 0 6px var(--surface), 0 0 0 7px var(--border);
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 14px;
    transition: box-shadow 0.4s, border-color 0.4s;
  }
  .timer-ring.active {
    border-color: var(--accent);
    box-shadow: inset 0 2px 12px rgba(0,0,0,0.4), 0 0 0 6px var(--surface), 0 0 0 7px var(--accent), 0 0 20px rgba(232,160,74,0.15);
  }
  .timer-digits {
    font-family: 'DM Mono', monospace;
    font-size: 42px;
    font-weight: 400;
    letter-spacing: 0.05em;
    color: var(--muted);
    transition: color 0.4s;
  }
  .timer-ring.active .timer-digits {
    color: var(--text);
  }
  .timer-status {
    font-size: 11px;
    font-weight: 500;
    letter-spacing: 0.2em;
    text-transform: uppercase;
    color: var(--muted);
    transition: color 0.4s;
  }
  .timer-status.active {
    color: var(--accent);
  }
  .btn-row { display: flex; gap: 10px; align-items: stretch; }
  .btn-row .btn { flex: 1; }
  .btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    border: none;
    border-radius: var(--radius-sm);
    cursor: pointer;
    font-family: inherit;
    font-size: 14px;
    font-weight: 500;
    padding: 12px 20px;
    transition: opacity 0.15s, transform 0.1s;
    width: 100%;
  }
  .btn:active { transform: scale(0.98); }
  .btn-primary {
    background: var(--accent);
    color: #0f0f11;
  }
  .btn-primary:hover { opacity: 0.88; }
  .btn-ghost {
    background: var(--surface2);
    color: var(--muted);
    border: 1px solid var(--border);
  }
  .btn-ghost:hover { color: var(--text); border-color: var(--muted); }
  .btn-danger {
    background: transparent;
    color: var(--error);
    border: 1px solid #3a2020;
  }
  .btn-danger:hover { background: #2a1515; }
  .btn + .btn:not(.btn-row .btn), .btn + .btn-stack-item { margin-top: 10px; }
  .status-pill {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    font-size: 12px;
    font-weight: 500;
    letter-spacing: 0.05em;
    padding: 4px 10px;
    border-radius: 999px;
    margin-bottom: 20px;
  }
  .pill-connected { background: #0d2a1a; color: var(--success); }
  .pill-ap        { background: #2a1f0d; color: var(--accent); }
  .dot {
    width: 6px; height: 6px;
    border-radius: 50%;
    background: currentColor;
    animation: pulse 2s infinite;
  }
  @keyframes pulse {
    0%,100% { opacity: 1; }
    50%      { opacity: 0.35; }
  }
  .network-list { display: flex; flex-direction: column; gap: 8px; margin-bottom: 16px; }
  .network-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    background: var(--surface2);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    padding: 12px 14px;
    cursor: pointer;
    transition: border-color 0.15s;
  }
  .network-item:hover { border-color: var(--accent); }
  .network-item.selected { border-color: var(--accent); background: #1e1a12; }
  .net-name { font-size: 14px; }
  .net-rssi { font-size: 12px; color: var(--muted); font-family: 'DM Mono', monospace; }
  .net-lock { font-size: 11px; color: var(--muted); margin-left: 8px; }
  .divider { border: none; border-top: 1px solid var(--border); margin: 20px 0; }
  .toast {
    position: fixed; bottom: 24px; left: 50%; transform: translateX(-50%) translateY(20px);
    background: var(--surface2); border: 1px solid var(--border);
    border-radius: var(--radius-sm); padding: 12px 20px;
    font-size: 13px; opacity: 0;
    transition: opacity 0.3s, transform 0.3s;
    pointer-events: none; white-space: nowrap;
  }
  .toast.show { opacity: 1; transform: translateX(-50%) translateY(0); }
  .toast.ok   { border-color: var(--success); color: var(--success); }
  .toast.err  { border-color: var(--error);   color: var(--error); }
  .field-group { margin-bottom: 4px; }
  .spinner {
    width: 16px; height: 16px;
    border: 2px solid transparent;
    border-top-color: currentColor;
    border-radius: 50%;
    animation: spin 0.7s linear infinite;
    display: none;
  }
  .loading .spinner { display: block; }
  .loading .btn-label { display: none; }
  @keyframes spin { to { transform: rotate(360deg); } }
  .ip-badge {
    font-family: 'DM Mono', monospace;
    font-size: 12px;
    color: var(--muted);
    background: var(--surface2);
    border: 1px solid var(--border);
    border-radius: 6px;
    padding: 3px 8px;
    display: inline-block;
    margin-top: 6px;
  }
</style>
<script>
function toast(msg, ok) {
  const t = document.getElementById('toast');
  t.textContent = msg;
  t.className = 'toast show ' + (ok ? 'ok' : 'err');
  clearTimeout(t._t);
  t._t = setTimeout(() => t.className = 'toast', 2800);
}
async function api(path, method, body) {
  try {
    const r = await fetch(path, {
      method, headers: {'Content-Type':'application/json'},
      body: body ? JSON.stringify(body) : undefined
    });
    return await r.json();
  } catch(e) { return { ok: false, error: e.message }; }
}
</script>
</head><body>
<div class="wordmark">
  <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
    <circle cx="9" cy="9" r="7" stroke="#e8a04a" stroke-width="1.5"/>
    <path d="M9 5v4l2.5 2.5" stroke="#e8a04a" stroke-width="1.5" stroke-linecap="round"/>
  </svg>
  )rawhtml";

// After wordmark text, close head structure
static const char HTML_WORDMARK_CLOSE[] PROGMEM = R"rawhtml(
</div>)rawhtml";

static const char HTML_FOOT[] PROGMEM = R"rawhtml(
<div id="toast" class="toast"></div>
</body></html>)rawhtml";

// ─── Setup Page (AP mode) ──────────────────────────────────────────────────────
static const char PAGE_SETUP[] PROGMEM = R"rawhtml(
<div class="card">
  <div class="card-title">Wi-Fi Setup</div>
  <div class="status-pill pill-ap"><span class="dot"></span>Setup Mode</div>
  <h1>Connect to your network</h1>
  <p style="margin-bottom:24px">Select a nearby Wi-Fi network to connect this device to your home.</p>

  <div id="networkList" class="network-list">
    <div style="color:var(--muted);font-size:13px">Scanning…</div>
  </div>

  <div class="field-group">
    <label for="ssid">Network name (SSID)</label>
    <input type="text" id="ssid" placeholder="My Network" autocomplete="off" spellcheck="false">
  </div>
  <div class="field-group">
    <label for="pass">Password</label>
    <input type="password" id="pass" placeholder="••••••••" autocomplete="new-password">
  </div>

  <button class="btn btn-primary" onclick="doConnect(this)">
    <span class="spinner"></span>
    <span class="btn-label">Connect</span>
  </button>
</div>

<script>
async function loadNetworks() {
  const d = await api('/api/wifi/scan','GET');
  const list = document.getElementById('networkList');
  if (!d.ok || !d.networks.length) {
    list.innerHTML = '<div style="color:var(--muted);font-size:13px">No networks found. <a href="#" onclick="loadNetworks();return false" style="color:var(--accent)">Retry</a></div>';
    return;
  }
  list.innerHTML = d.networks
    .sort((a,b)=>b.rssi-a.rssi)
    .map(n=>`<div class="network-item" onclick="selectNet(this,'${escHtml(n.ssid)}',${n.open})">
      <span class="net-name">${escHtml(n.ssid)}<span class="net-lock">${n.open?'':'🔒'}</span></span>
      <span class="net-rssi">${rssiLabel(n.rssi)}</span>
    </div>`).join('');
}
function escHtml(s) { return s.replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c])); }
function rssiLabel(r) { return r>=-55?'▂▄▆█':r>=-70?'▂▄▆_':r>=-80?'▂▄__':'▂___'; }
function selectNet(el, ssid, open) {
  document.querySelectorAll('.network-item').forEach(e=>e.classList.remove('selected'));
  el.classList.add('selected');
  document.getElementById('ssid').value = ssid;
  if (open) document.getElementById('pass').value = '';
  document.getElementById('pass').focus();
}
async function doConnect(btn) {
  const ssid = document.getElementById('ssid').value.trim();
  const pass = document.getElementById('pass').value;
  if (!ssid) { toast('Please enter a network name', false); return; }
  btn.classList.add('loading');
  const d = await api('/api/wifi/connect','POST',{ssid,password:pass});
  btn.classList.remove('loading');
  if (d.ok) toast('Connecting… device will reboot', true);
  else toast(d.error || 'Failed', false);
}
loadNetworks();
</script>
)rawhtml";

// ─── Main Page (STA connected mode) ───────────────────────────────────────────
static const char PAGE_MAIN[] PROGMEM = R"rawhtml(
<div class="card" id="statusCard">
  <div class="card-title">Status</div>
  <div class="status-pill pill-connected"><span class="dot"></span>Connected</div>
  <h1 id="devName">Device</h1>
  <div class="ip-badge" id="ipBadge">—</div>
</div>

<div class="card">
  <div class="card-title">Timer</div>

  <div class="timer-face">
    <div class="timer-ring">
      <div id="timerDisplay" class="timer-digits">--:--</div>
    </div>
    <div id="timerStatus" class="timer-status">standby</div>
  </div>

  <div id="timerButtons" class="btn-row">
    <button class="btn btn-primary" onclick="doStartTimer(this, 600000)">
      <span class="spinner"></span>
      <span class="btn-label">Start 10m</span>
    </button>
    <button class="btn btn-primary" onclick="doStartTimer(this, 1200000)">
      <span class="spinner"></span>
      <span class="btn-label">Start 20m</span>
    </button>
  </div>
</div>

<div class="card">
  <div class="card-title">Controls</div>
  <button class="btn btn-primary" onclick="doDispense(this)">
    <span class="spinner"></span>
    <span class="btn-label">Dispense</span>
  </button>
  <button class="btn btn-primary" onclick="doHelloWorld(this)">
    <span class="spinner"></span>
    <span class="btn-label">Hello World</span>
  </button>
</div>

<script>
let _timerInterval  = null;
let _timerSyncInterval = null;
let _msRemaining    = 0;

function formatTime(ms) {
  const totalSec = Math.max(0, Math.floor(ms / 1000));
  const m = Math.floor(totalSec / 60).toString().padStart(2, '0');
  const s = (totalSec % 60).toString().padStart(2, '0');
  return m + ':' + s;
}

function startClientTimer(msRemaining) {
  _msRemaining = msRemaining;

  document.getElementById('timerButtons').style.display  = 'none';
  document.getElementById('timerDisplay').textContent    = formatTime(_msRemaining);
  document.getElementById('timerStatus').textContent     = 'running';
  document.querySelector('.timer-ring').classList.add('active');
  document.getElementById('timerStatus').classList.add('active');

  clearInterval(_timerInterval);
  _timerInterval = setInterval(() => {
    _msRemaining -= 1000;
    document.getElementById('timerDisplay').textContent = formatTime(_msRemaining);
    if (_msRemaining <= 0) stopClientTimer();
  }, 1000);

  clearInterval(_timerSyncInterval);
  _timerSyncInterval = setInterval(syncTimerStatus, 10000);
}

function stopClientTimer() {
  clearInterval(_timerInterval);
  clearInterval(_timerSyncInterval);
  _timerInterval     = null;
  _timerSyncInterval = null;
  _msRemaining       = 0;

  document.getElementById('timerButtons').style.display  = '';
  document.getElementById('timerDisplay').textContent    = '--:--';
  document.getElementById('timerStatus').textContent     = 'standby';
  document.querySelector('.timer-ring').classList.remove('active');
  document.getElementById('timerStatus').classList.remove('active');
}

async function syncTimerStatus() {
  const d = await api('/api/timer/status', 'GET');
  if (!d.ok) return;
  if (!d.inProgress) {
    stopClientTimer();
  } else {
    // Correct any drift
    _msRemaining = d.msRemaining;
  }
}

// Check timer status on page load in case timer is already running
syncTimerStatus().then(() => {
  if (_msRemaining > 0) startClientTimer(_msRemaining);
});
</script>

<div class="card">
  <div class="card-title">Network</div>
  <p id="wifiSSID" style="margin-bottom:16px">—</p>
  <hr class="divider">
  <button class="btn btn-danger" onclick="doForget(this)">
    <span class="spinner"></span>
    <span class="btn-label">Forget network &amp; reset Wi-Fi</span>
  </button>
</div>

<script>
async function loadStatus() {
  const d = await api('/api/status','GET');
  if (!d.ok) return;
  document.getElementById('devName').textContent  = d.device;
  document.getElementById('ipBadge').textContent  = d.wifi.ip;
  document.getElementById('wifiSSID').textContent = 'Connected to: ' + d.wifi.ssid;
}
async function doDispense(btn) {
  btn.classList.add('loading');
  const d = await api('/api/dispense','POST');
  btn.classList.remove('loading');
  toast(d.ok ? d.message : (d.error||'Error'), d.ok);
}
async function doHelloWorld(btn) {
  btn.classList.add('loading');
  const d = await api('/api/helloworld','POST');
  btn.classList.remove('loading');
  toast(d.ok ? d.message : (d.error||'Error'), d.ok);
}
async function doStartTimer(btn, durationMs) {
  btn.classList.add('loading');
  const d = await api('/api/timer/start', 'POST', { durationMs });
  btn.classList.remove('loading');
  if (d.ok) startClientTimer(d.msRemaining);
  else toast(d.error || 'Failed', false);
}
async function doForget(btn) {
  if (!confirm('This will disconnect the device from Wi-Fi and restart setup mode.')) return;
  btn.classList.add('loading');
  const d = await api('/api/wifi/forget','POST');
  if (!d.ok) { btn.classList.remove('loading'); toast(d.error||'Error', false); }
  else toast('Rebooting into setup mode…', true);
}
loadStatus();
</script>
)rawhtml";

// ─── Route helpers ─────────────────────────────────────────────────────────────

// Sends a full HTML page assembled from shared head + content + foot.
static void sendPage(const char* title, const char* content) {
  String html;
  html.reserve(8192);
  html += FPSTR(HTML_HEAD);
  html += title;
  html += FPSTR(HTML_STYLE);
  html += FPSTR(HTML_WORDMARK_CLOSE);
  html += title;
  html += FPSTR(HTML_WORDMARK_CLOSE);   // close wordmark div
  html += content;
  html += FPSTR(HTML_FOOT);
  _server.send(200, "text/html", html);
}

// ─── Route registration ────────────────────────────────────────────────────────
// ★ ADD NEW ROUTES HERE — one line per endpoint.

static void registerAPIRoutes() {
  _server.on("/api/dispense",      HTTP_POST, []{ APIHandlers::dispense(_server);    });
  _server.on("/api/helloworld",    HTTP_POST, []{ APIHandlers::helloWorld(_server);    });
  _server.on("/api/timer/status",  HTTP_GET,  []{ APIHandlers::timerStatus(_server); });
  _server.on("/api/timer/start",   HTTP_POST, []{ APIHandlers::timerStart(_server);    });
  _server.on("/api/wifi/connect",  HTTP_POST, []{ APIHandlers::wifiConnect(_server); });
  _server.on("/api/wifi/forget",   HTTP_POST, []{ APIHandlers::wifiForget(_server);  });
  _server.on("/api/wifi/scan",     HTTP_GET,  []{ APIHandlers::wifiScan(_server);    });
  _server.on("/api/status",        HTTP_GET,  []{ APIHandlers::status(_server);      });
}

static void registerPageRoutes() {
  bool connected = WiFiManager::isConnected();

  _server.on("/", HTTP_GET, [connected]() {
    if (connected) sendPage(DEVICE_NAME, PAGE_MAIN);
    else           sendPage(DEVICE_NAME, PAGE_SETUP);
  });

  _server.onNotFound([connected]() {
    if (connected) sendPage(DEVICE_NAME, PAGE_MAIN);
    else           sendPage(DEVICE_NAME, PAGE_SETUP);
  });
}

// ─── Public API ───────────────────────────────────────────────────────────────

namespace WebServerManager {

void begin() {
  registerAPIRoutes();
  registerPageRoutes();
  _server.begin(HTTP_PORT);
  Serial.printf("[HTTP] Listening on port %d\n", HTTP_PORT);
}

void tick() {
  _server.handleClient();
  APIHandlers_tick();
}

} // namespace WebServerManager
