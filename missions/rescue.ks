runPath("../lib/ui_lib.ks").
runPath("../lib/staging_lib.ks").
runPath("../lib/circ_lib.ks").
runPath("../lib/launch_lib.ks").
runPath("../lib/landing_lib.ks").
runPath("../lib/rocket_utils_lib.ks").
runPath("../lib/hohhman_lib.ks").
runPath("../lib/rendezvous_lib.ks").
runPath("../lib/transfer_lib.ks").

parameter missionStatus is 1.
parameter targetApo is 80000.

if missionStatus = 1{
  launch(3).
  set missionStatus to 2.
}
if missionStatus = 2 {
  gravityTurn(targetApo).
  set missionStatus to 3.
}
if missionStatus = 3 {
  waitUntilEndOfAtmosphere().
  set missionStatus to 4.
}
  
if missionStatus = 4 {
  raisePeriapsis(targetApo).
  set missionStatus to 5.
}

if missionStatus = 5 {
  changePeriod().
  set missionStatus to 6.
}

if missionStatus = 6 {
  approcheTarget(10).
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
