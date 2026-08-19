#include "stepper_manager.h"
#include "config.h"

/*
 * ms_exp | ms_mult  | Mode      | ms_setup_exp  | dec2bin | ms3 | ms2 | ms1
 *      0 | 2^0 =  1 | Full step |             0 |     000 |   0 |   0 |   0
 *      1 | 2^1 =  2 | Half step |             1 |     001 |   0 |   0 |   1
 *      2 | 2^2 =  4 |  Qtr step |             2 |     010 |   0 |   1 |   0
 *      3 | 2^3 =  8 |  1/8 step |             3 |     011 |   0 |   1 |   1
 *      4 | 2^4 = 16 | 1/16 step |             7 |     111 |   1 |   1 |   1
 */
constexpr int microstep_setup_exponent = microstep_exponent + (microstep_exponent==4?3:0);
constexpr bool ms3 = ((int)floor(microstep_setup_exponent/4) % 2) == 1;
constexpr bool ms2 = ((int)floor(microstep_setup_exponent/2) % 2) == 1;
constexpr bool ms1 = microstep_setup_exponent % 2 ==1 ;

namespace StepperManager {
  SpeedyStepper stepper;

  void begin() {
    //Set up microstepping
    pinMode(PIN_MS3, OUTPUT);
    pinMode(PIN_MS2, OUTPUT);
    pinMode(PIN_MS1, OUTPUT);
    digitalWrite(PIN_MS3, (ms3 ? HIGH : LOW));
    digitalWrite(PIN_MS2, (ms2 ? HIGH : LOW));
    digitalWrite(PIN_MS1, (ms1 ? HIGH : LOW));

    //setup the enable pin
    pinMode(MOTOR_ENABLE_PIN, OUTPUT);
    digitalWrite(MOTOR_ENABLE_PIN, HIGH);

    stepper.connectToPins(MOTOR_STEP_PIN, MOTOR_DIRECTION_PIN);
    stepper.setStepsPerRevolution(200*microstep_multiple);
    stepper.setCurrentPositionInRevolutions(0);
    //stepper.setSpeedInStepsPerSecond(2000);
    //stepper.setAccelerationInStepsPerSecondPerSecond(500);
    stepper.setSpeedInRevolutionsPerSecond(2);
    stepper.setAccelerationInRevolutionsPerSecondPerSecond(1000);

    //turn the stepper on for a moment to allow it to get into the correct phase
    //this will cause a jerk, which we want to happen now, and not later when we want to start feeding
    digitalWrite(MOTOR_ENABLE_PIN, LOW);
    delay(100);
    digitalWrite(MOTOR_ENABLE_PIN, HIGH);
  }
}
