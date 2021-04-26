runPath("../lib/ui_lib.ks").
runPath("../lib/staging_lib.ks").
runPath("../lib/circ_lib.ks").
runPath("../lib/launch_lib.ks").
runPath("../lib/landing_lib.ks").
runPath("../lib/rocket_utils_lib.ks").
runPath("../lib/hohhman_lib.ks").
runPath("../lib/utils_lib.ks").
runPath("../lib/wait_lib.ks").
runPath("../lib/warp_lib.ks").

clearScreen.
parameter missionStatus is 0.
parameter targetApo is 80000.
parameter unpack is true.

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
  waitUntilEndOfAtmosphere(unpack).
  set missionStatus to 3.
}
if(missionStatus = 3) {
  raisePeriapsis(targetApo).
  set missionStatus to 4.
}