runPath("../lib/ui_lib.ks").
runPath("../lib/staging_lib.ks").
runPath("../lib/circ_lib.ks").
runPath("../lib/launch_lib.ks").
runPath("../lib/landing_lib.ks").
runPath("../lib/rocket_utils_lib.ks").
runPath("../lib/hohhman_lib.ks").

clearScreen.
parameter missionStatus is 0.
parameter targetApo is 80000.

print "========KERBINTOURS========".
print "APOAPSIS:".
print "PERIAPSIS:".
print "ALTITUDE:".
print "========Event log========".


if(missionStatus = 0) {
  launch(3).
  set missionStatus to 1.
}
if(missionStatus = 1) {
  gravityTurn(targetApo).
  set missionStatus to 2.
}
if(missionStatus = 2) {
  waitUntilEndOfAtmosphere().
  set missionStatus to 4.
}
if(missionStatus = 4) {
  raisePeriapsis().
  set missionStatus to 5.
}
if(missionStatus = 5) {
  wait 20.
  if obt:eccentricity > 0.0005 {
    waitToApoapsis().
  }
  set missionStatus to 6.
}
if(missionStatus = 6) {
  deOrbitBurn().
  set missionStatus to 7.
}
if(missionStatus = 7) {
  waitToEnterToATM().
  set missionStatus to 8.
}
if(missionStatus = 8) {
  doSafeParachute().
  printO("KERBINTOURS","TOUCHDOWN").
}