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

if missionStatus < 5 {
  run parkingOrbit(targetApo).
  set missionStatus to 5.
}

print "========KERBINTOURS========".
print "APOAPSIS:".
print "PERIAPSIS:".
print "ALTITUDE:".
print "========Event log========".


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