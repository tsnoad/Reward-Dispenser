# Reward Dispenser

## What the?

## Bill of materials

| No. | Part | Notes/source |
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
|    Neopixel `DIN` | ![Wiring diagram](resources/wire_white.svg)  | `GPIO 5` |  |    `5V`  | ![Wiring diagram](resources/wire_double_red.svg)   | Neopixel `VIN` <br />**+** Buck Converter `VIN` |
|       A4988 `Dir` | ![Wiring diagram](resources/wire_blue.svg)   | `GPIO 6` |  |    `GND` | ![Wiring diagram](resources/wire_double_black.svg) | Neopixel `GND` <br />**+** Buck Converter `GND` |
|      A4988 `Step` | ![Wiring diagram](resources/wire_yellow.svg) | `GPIO 7` |  |    `3V3` | ![Wiring diagram](resources/wire_red.svg)   | A4988 `VDD` |
|    A4988 `Enable` | ![Wiring diagram](resources/wire_white.svg)  | `GPIO 8` |  | `GPIO 4` |                                             | *not connected* |
| *not connected* |                                              | `GPIO 9` |  | `GPIO 3` |                                             | *not connected* |
|       A4988 `MS1` | ![Wiring diagram](resources/wire_green.svg) | `GPIO 10` |  | `GPIO 2` |                                             | *not connected* |
|       A4988 `MS2` | ![Wiring diagram](resources/wire_green.svg) | `GPIO 20` |  | `GPIO 1` |                                             | *not connected* |
|       A4988 `MS3` | ![Wiring diagram](resources/wire_green.svg) | `GPIO 21` |  | `GPIO 0` |                                             | *not connected* |


### Buck converter connections

| Buck Converter Pin |  | To |
| --: | --- | :-- |
| `VIN` (5V) | ![Wiring diagram](resources/wire_red.svg) | ESP32C3 `5V` |
| `GND` | ![Wiring diagram](resources/wire_double_black.svg) | ESP32C3 `GND` <br />**+** A4988 `GND` |
| `VOUT` (12V) | ![Wiring diagram](resources/wire_red.svg) | A4988 `VMOT` |

### A4988 connections

| To |  | A4988 Pin |  | A4988 Pin |  | To |
| --: | --- | :-- | --- | --: | --- | :-- |
|  ESP32C3 `GPIO 5` | ![Wiring diagram](resources/wire_blue.svg)   | `Dir`    |  |  `GND` |                                              | *not connected* |
|  ESP32C3 `GPIO 6` | ![Wiring diagram](resources/wire_yellow.svg) | `Step`   |  |  `VDD` | ![Wiring diagram](resources/wire_red.svg)    | ESP32C3 `3V3` |
|  *Internal pull-up\** |                                              | `Sleep`  |  |   `Out 1B` | ![Wiring diagram](resources/wire_black.svg)  | Stepper Motor `1B` |
|  *Jump to `Sleep` pin\** |                                              | `Reset`  |  |   `Out 1A` | ![Wiring diagram](resources/wire_white.svg)  | Stepper Motor `1A` |
| ESP32C3 `GPIO 10` | ![Wiring diagram](resources/wire_green.svg)  | `MS1`    |  |   `Out 2A` | ![Wiring diagram](resources/wire_yellow.svg) | Stepper Motor `2A` |
| ESP32C3 `GPIO 20` | ![Wiring diagram](resources/wire_green.svg)  | `MS2`    |  |   `Out 2B` | ![Wiring diagram](resources/wire_green.svg)  | Stepper Motor `2B` |
| ESP32C3 `GPIO 21` | ![Wiring diagram](resources/wire_green.svg)  | `MS3`    |  |  `GND` | ![Wiring diagram](resources/wire_black.svg)  | Buck Converter `GND` |
|  ESP32C3 `GPIO 8` | ![Wiring diagram](resources/wire_white.svg)  | `Enable` |  | `VMOT` | ![Wiring diagram](resources/wire_red.svg)    | Buck Converter `VOUT` |

\* On most A4988 boards the `Sleep` pin has a pull-up resistor, but the `Reset` pin. By jumping `Reset` to `Sleep` will also be pulled-u

### Setting the current limit for A4988 stepper motor driver

$$ I_{TripMAX} = \frac{V_{REF}}{8 \times R_S} $$
$$ V_{REF} = \frac{I_{TripMAX}}{8 \times R_S} $$
$$ V_{REF} = \frac{0.8 \mathrm{A} \times \mathrm{80\%} }{8 \times 0.1 \mathrm{\Omega}} = 0.8 \mathrm{V} $$

### Build instructions

## Software

### Stand-alone API

### HomeAssistant/ESPHome

## Licence

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC_BY_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)
