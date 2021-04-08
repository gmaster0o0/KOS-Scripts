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
  set missionStatus to 3.
}
if(missionStatus = 3) {
  //waitToApoapsis().
  set missionStatus to 4.
}
if(missionStatus = 4) {
  raisePeriapsis().
  set missionStatus to 5.
}