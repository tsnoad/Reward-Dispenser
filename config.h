#pragma once

// ─── Device Identity ──────────────────────────────────────────────────────────
#define DEVICE_NAME        "SmartDevice"
#define FIRMWARE_VERSION   "1.0.0"

// ─── AP (Hotspot) Settings ────────────────────────────────────────────────────
#define AP_SSID            "SmartDevice-Setup"
#define AP_PASSWORD        ""           // Leave empty for open AP
#define AP_IP              "192.168.4.1"

// ─── NVS Storage Keys ─────────────────────────────────────────────────────────
#define NVS_NAMESPACE      "device_cfg"
#define NVS_KEY_SSID       "wifi_ssid"
#define NVS_KEY_PASS       "wifi_pass"

// ─── GPIO Pins ────────────────────────────────────────────────────────────────
#define PIN_DISPENSE       GPIO_NUM_3   // Change to your target GPIO

// ─── Timing ───────────────────────────────────────────────────────────────────
#define DISPENSE_ON_MS     2000         // How long the dispense GPIO stays HIGH
#define WIFI_CONNECT_TIMEOUT_MS 10000  // Max time to wait for STA connection

// ─── HTTP ─────────────────────────────────────────────────────────────────────
#define HTTP_PORT          80

const int MOTOR_STEP_PIN = 3;
const int MOTOR_DIRECTION_PIN = 1;
const int MOTOR_ENABLE_PIN = 0;
//output pins to configure microstepping
const int PIN_MS1 = 5;
const int PIN_MS2 = 6;
const int PIN_MS3 = 7;

/*
 * Microstepping multiple
 * 0 => Full step
 * 1 => Half step
 * 2 => Quarter step
 * 3 => 8th step
 * 4 => 16th step
 */
const int microstep_exponent = 4;


#define PIN_NEOPIXEL 4
#define NEOPIXEL_COUNT 3 // How many NeoPixels are attached to the Arduino?