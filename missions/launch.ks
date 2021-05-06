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
parameter targetApo is 80.
parameter unpack is true.

if(missionStatus = 0) {
  clearScreen.
  print "PRESS ABORT FOR LAUNCH!" at (30,10).
  wait until abort.
  clearScreen.
  set abort to false.

  launch(3).
  set missionStatus to 1.
}

print "=====================================" at (60,0).
print "|APOAPSIS:    " at (60,1).
print "|PERIAPSIS:   " at (60,2). 
print "|ALTITUDE:    " at (60,3).
print "|SHIP:Q:      " at (60,4).
print "|Max Q:       " at (60,5).
print "|TWR:         " at (60,6).
print "|Pitch:       " at (60,7).
print "=====================================" at (60,8).
print "========Event log================================================================".

local startingDV is ship:deltaV:current.

if(missionStatus = 1) {
  gravityTurn(targetApo*1000).
  set missionStatus to 2.
}
if(missionStatus = 2) {
  waitUntilEndOfAtmosphere(unpack,targetApo*1000).
  set missionStatus to 3.
}
if(missionStatus = 3) {
  raisePeriapsis().
  set missionStatus to 4.
}
//LOG  (startingDV - ship:deltaV:current) to "0:/dv.txt". 
print startingDV - ship:deltaV:current.