# Reward Dispenser

## What the?

## Bill of materials

|  |  |  |
| :-- | :-- | :-- |
| 1 | ESP32-C3 super-mini | |
| 1 | 3.5A 12V DC-DC boost converter (DD0612SA) | https://www.aliexpress.com/item/32828353177.html |
| 1 | A4988 stepper motor driver | |
| 1 | NEMA 17 stepper motor (17HD4063-01N) | |
| 1 | WS2612B LED strip 60 LED/m | |
| 1 | 5mm flange shaft coupler | https://www.aliexpress.com/item/1005005292070050.html |
| 8 | M3x8mm self-tapping flat-end countersunk plastic screws | |
| 4 | M3x10mm machine screws (Security torx optional) | |
| 4 | M3x5x5 heatset inserts | https://www.aliexpress.com/item/1005003582355741.html |
| 4 | FC-040 rubber feet | https://www.aliexpress.com/item/1005005473504763.html |

## Wiring

### ESP32 C3 connections

| To |  | ESP32 Pin |  | ESP32 Pin |  | To |
| --: | --- | :-- | --- | --: | --- | :-- |
|    Neopixel DIN | ![Wiring diagram](resources/wire_white.svg)  | 5 |  | 5V  | ![Wiring diagram](resources/wire_double_red.svg)   | Neopixel VIN <br />**+**<br /> Buck Converter VIN |
|       A4988 Dir | ![Wiring diagram](resources/wire_blue.svg)   | 6 |  | GND | ![Wiring diagram](resources/wire_double_black.svg) | Neopixel GND <br />**+**<br /> Buck Converter GND |
|      A4988 Step | ![Wiring diagram](resources/wire_yellow.svg) | 7 |  | 3V3 | ![Wiring diagram](resources/wire_red.svg)   | A4988 VDD |
|    A4988 Enable | ![Wiring diagram](resources/wire_white.svg)  | 8 |  | 4   |                                             | *not connected* |
| *not connected* |                                              | 9 |  | 4   |                                             | *not connected* |
|       A4988 MS1 | ![Wiring diagram](resources/wire_green.svg) | 10 |  | 4   |                                             | *not connected* |
|       A4988 MS2 | ![Wiring diagram](resources/wire_green.svg) | 20 |  | 4   |                                             | *not connected* |
|       A4988 MS3 | ![Wiring diagram](resources/wire_green.svg) | 21 |  | 4   |                                             | *not connected* |


### Buck converter connections

| Buck Converter Pin |  | To |
| --: | --- | :-- |
| VIN (5V) | ![Wiring diagram](resources/wire_red.svg) | ESP32C3 5V |
| GND | ![Wiring diagram](resources/wire_double_black.svg) | ESP32C3 GND <br />**+**<br /> A4988 GND |
| Vout (12V) | ![Wiring diagram](resources/wire_red.svg) | A4988 VMOT |

### A4988 connections

| To |  | A4988 Pin |  | A4988 Pin |  | To |
| --: | --- | :-- | --- | --: | --- | :-- |
|  ESP32C3 GPIO5 | ![Wiring diagram](resources/wire_blue.svg)   | Dir    |  |  GND |                                              | *not connected* |
|  ESP32C3 GPIO6 | ![Wiring diagram](resources/wire_yellow.svg) | Step   |  |  VDD | ![Wiring diagram](resources/wire_red.svg)    | ESP32C3 3V3 |
| Jump to Reset* |                                              | Sleep  |  |   1A | ![Wiring diagram](resources/wire_black.svg)  | Stepper Motor 1B |
| Jump to Sleep* |                                              | Reset  |  |   2A | ![Wiring diagram](resources/wire_white.svg)  | Stepper Motor 1A |
| ESP32C3 GPIO10 | ![Wiring diagram](resources/wire_green.svg)  | MS1    |  |   2B | ![Wiring diagram](resources/wire_yellow.svg) | Stepper Motor 2A |
| ESP32C3 GPIO20 | ![Wiring diagram](resources/wire_green.svg)  | MS2    |  |   2B | ![Wiring diagram](resources/wire_green.svg)  | Stepper Motor 2B |
| ESP32C3 GPIO21 | ![Wiring diagram](resources/wire_green.svg)  | MS3    |  |  GND | ![Wiring diagram](resources/wire_black.svg)  | Buck Converter GND |
|  ESP32C3 GPIO8 | ![Wiring diagram](resources/wire_white.svg)  | Enable |  | VMOT | ![Wiring diagram](resources/wire_red.svg)    | Buck Converter VOUT |

### Setting the current limit for A4988 stepper motor driver

### Build instructions

## Software

### Stand-alone API

### HomeAssistant/ESPHome

## Licence

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC_BY_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)
