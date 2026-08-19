#pragma once

// ─── Device Identity ──────────────────────────────────────────────────────────
#define DEVICE_NAME        "SmartDevice"
#define FIRMWARE_VERSION   "1.0.0"

// ─── AP (Hotspot) Settings ────────────────────────────────────────────────────
#define AP_SSID            "SmartDevice-Setup"
#define AP_PASSWORD        "smartdevice123"
// #define AP_IP              "10.0.0.1" // this is actually hardcoded into WifiManager::startAP()

// ─── NVS Storage Keys ─────────────────────────────────────────────────────────
#define NVS_NAMESPACE      "device_cfg"
#define NVS_KEY_SSID       "wifi_ssid"
#define NVS_KEY_PASS       "wifi_pass"

// ─── Timing ───────────────────────────────────────────────────────────────────
constexpr int WIFI_CONNECT_TIMEOUT_MS = 10000;  // Max time to wait for STA connection

// ─── HTTP ─────────────────────────────────────────────────────────────────────
constexpr int HTTP_PORT = 80;

// ─── Stepper ──────────────────────────────────────────────────────────────────
constexpr gpio_num_t MOTOR_DIRECTION_PIN = GPIO_NUM_6;
constexpr gpio_num_t MOTOR_STEP_PIN      = GPIO_NUM_7;
constexpr gpio_num_t MOTOR_ENABLE_PIN    = GPIO_NUM_8;

//output pins to configure microstepping
constexpr gpio_num_t PIN_MS1 = GPIO_NUM_21;
constexpr gpio_num_t PIN_MS2 = GPIO_NUM_20;
constexpr gpio_num_t PIN_MS3 = GPIO_NUM_10;

/*
 * Microstepping exponent
 * 0 => Full step
 * 1 => Half step
 * 2 => Quarter step
 * 3 => 8th step
 * 4 => 16th step
 */
constexpr int microstep_exponent = 3;
constexpr int microstep_multiple = pow(2,microstep_exponent);

constexpr int parking_offset_rot = 20; //20.0534 degrees

constexpr float revolutions_to_feed_position = (180-(float)parking_offset_rot)/360;
constexpr float revolutions_to_nextfeed_position = 0.5;
constexpr float revolutions_to_standby_position = revolutions_to_nextfeed_position-revolutions_to_feed_position;

// ─── Neopixel ─────────────────────────────────────────────────────────────────
constexpr gpio_num_t PIN_NEOPIXEL_DATA = GPIO_NUM_5;
constexpr int NEOPIXEL_COUNT = 3; // How many NeoPixels are attached to the Arduino?
constexpr int NEOPIXEL_TICK_MS = 50;