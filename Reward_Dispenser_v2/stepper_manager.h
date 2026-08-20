#pragma once
#include <SpeedyStepper.h>

namespace StepperManager {
  extern SpeedyStepper stepper;

  enum class StepperDispenseState { IDLE, MOVING_TO_POS1, MOVING_TO_POS2 };
  StepperDispenseState getStepperDispenseState();

  void begin();
  void tick();
  void startStepperDispense();
  void startMoveToStandbyStepperDispense();
  void finishStepperDispense();
}