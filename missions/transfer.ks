runPath("../lib/ui_lib.ks").
runPath("../lib/staging_lib.ks").
runPath("../lib/circ_lib.ks").
runPath("../lib/launch_lib.ks").
runPath("../lib/landing_lib.ks").
runPath("../lib/rocket_utils_lib.ks").
runPath("../lib/hohhman_lib.ks").
runPath("../lib/transfer_lib.ks").
runPath("../lib/warp_lib.ks").
runPath("../lib/wait_lib.ks").
runPath("../lib/utils_lib.ks").

parameter missionStatus is 0.

local targetBody is MUN.
if missionStatus = 0 {
  print "PRESS ABORT FOR LAUNCH!" at (30,10).
  wait until abort.
  clearScreen.
  set abort to false.
  set missionStatus to 1.
}

if hasTarget {
  set targetBody  to target.
}

//LAUNCH TO PARKING ORBIT.
if missionStatus < 5 {
  run launch.
  set missionStatus to 5.
}
clearScreen.

print "========KERBINTOURS========" at(40,0).
print "targetAng:" at(40,1).
print "ETAofTransfer:" at(40,2).
print "angleChangeRate:" at(40,3).
print "========Event log========" at(40,4).

if(missionStatus = 5) {
  set target to targetBody.
  waitForTransferWindow().
  set missionStatus to 6.
}
if(missionStatus = 6) {
  doOrbitTransfer().
  set missionStatus to 7.
}
if(missionStatus = 7) {
  waitToEncounter(targetBody).
  set missionStatus to 8.
}
if(missionStatus = 8) {
  avoidCollision().
  set missionStatus to 9.
}
if(missionStatus = 9){
  lowerApoapsis().
}



