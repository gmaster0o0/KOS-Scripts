runPath("../lib/ui_lib.ks").
runPath("../lib/staging_lib.ks").
runPath("../lib/circ_lib.ks").
runPath("../lib/launch_lib.ks").
runPath("../lib/landing_lib.ks").
runPath("../lib/rocket_utils_lib.ks").
runPath("../lib/hohhman_lib.ks").
runPath("../lib/rendezvous_lib.ks").
runPath("../lib/transfer_lib.ks").
runPath("../lib/utils_lib.ks").
runPath("../lib/wait_lib.ks").
runPath("../lib/warp_lib.ks").

parameter missionStatus is 1.
parameter targetDistance is 100.
parameter turningTime is 10.
parameter fast is true.

local targetApo is target:apoapsis.

//LAUNCH TO PARKING ORBIT.
if missionStatus < 5 {
  run launch(0,targetApo).
  set missionStatus to 5.
}
clearScreen.

if missionStatus = 5 {
  changePeriod().
  set missionStatus to 6.
}

if missionStatus = 6 {
  approcheTarget(targetDistance,turningTime,fast).
  set missionStatus to 7.
}

if missionStatus = 7 {
  killRelVel(0.01).
  set missionStatus to 8.
}

if missionStatus = 8 {
  finishRendezvous().
  set missionStatus to 9.
}
