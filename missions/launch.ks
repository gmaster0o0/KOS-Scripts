runPath("../lib/ui_lib.ks").
runPath("../lib/staging_lib.ks").
runPath("../lib/change_orbit_lib.ks").
runPath("../lib/launch_lib.ks").
runPath("../lib/landing_lib.ks").
runPath("../lib/rocket_utils_lib.ks").
runPath("../lib/hohhman_lib.ks").
runPath("../lib/utils_lib.ks").
runPath("../lib/wait_lib.ks").
runPath("../lib/warp_lib.ks").
runOncePath("../lib/node_lib.ks").

clearScreen.
parameter missionStatus is 0.
parameter targetApo is 80.
parameter unpack is true.

if(missionStatus = 0) {
  clearScreen.
  //print "PRESS AG1 FOR LAUNCH!" at (30,10).
  //wait until ag1.
  clearScreen.
  //set ag1 to false.
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
print "========Event log============================".

local _circ is ChangeOrbitLib().

if missionStatus = 1 {
  launch(3).
  set missionStatus to 2. 
}
if(missionStatus = 2) {
  gravityTurn(targetApo*1000).
  set missionStatus to 3.
}
if(missionStatus = 3) {
  waitUntilEndOfAtmosphere(unpack,targetApo*1000).
  set missionStatus to 4.
}
if(missionStatus = 4) {
  _circ:ellipseToCircle().
  nodeLib:execute(nextNode, true).
  set missionStatus to 5.
}