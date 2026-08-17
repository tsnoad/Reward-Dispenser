#include "stepper_manager.h"
#include "config.h"  // define PIN_NEOPIXEL and NEOPIXEL_COUNT here




const int parking_offset_rot = 20; //20.0534 degrees

namespace StepperManager {
  SpeedyStepper stepper;

  void begin() {
    //Set up stepper
    int microstep_exponent_adj = microstep_exponent + (microstep_exponent==4?3:0);
    int microstep_multiple = pow(2,microstep_exponent_adj);

    bool ms3 = ((int)floor(microstep_exponent_adj/4) % 2) == 1;
    bool ms2 = ((int)floor(microstep_exponent_adj/2) % 2) == 1;
    bool ms1 = microstep_exponent_adj % 2 ==1 ;

    pinMode(PIN_MS3, OUTPUT);
    pinMode(PIN_MS2, OUTPUT);
    pinMode(PIN_MS1, OUTPUT);
    digitalWrite(PIN_MS3, (ms3 ? HIGH : LOW));
    digitalWrite(PIN_MS2, (ms2 ? HIGH : LOW));
    digitalWrite(PIN_MS1, (ms1 ? HIGH : LOW));

    pinMode(MOTOR_ENABLE_PIN, OUTPUT);
    digitalWrite(MOTOR_ENABLE_PIN, HIGH);

    stepper.connectToPins(MOTOR_STEP_PIN, MOTOR_DIRECTION_PIN);
    stepper.setStepsPerRevolution(200);
    stepper.setCurrentPositionInRevolutions(0);
    //stepper.setSpeedInStepsPerSecond(2000);
    //stepper.setAccelerationInStepsPerSecondPerSecond(500);
    stepper.setSpeedInRevolutionsPerSecond(4);
    stepper.setAccelerationInRevolutionsPerSecondPerSecond(2);

    //turn the stepper on for a moment to allow it to get into the correct phase
    //this will cause a jerk, which we want to happen now, and not later when we want to start feeding
    digitalWrite(MOTOR_ENABLE_PIN, LOW);
    digitalWrite(MOTOR_ENABLE_PIN, HIGH);
  }
}
