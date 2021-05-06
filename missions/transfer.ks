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

if hasTarget {
  set targetBody  to target.
}

//LAUNCH TO PARKING ORBIT.
if missionStatus < 5 {
  run launch(missionStatus).

  set missionStatus to 5.
}
clearScreen.

print "========KERBINTOURS========" at(60,0).
print "targetAng:" at(60,1).
print "ETAofTransfer:" at(60,2).
print "angleChangeRate:" at(60,3).
print "========Event log========" at(60,4).

if(missionStatus = 5) {
  set target to targetBody.
  local relInc is relativeInc(ship,targetBody).
  until abs(relInc) < 1 {
    run changeinc.
    set relInc to relativeInc(ship,targetBody).
  }
  rcs off.
  until obt:eccentricity < 0.0005 {
    run launch(3).
  }
  rcs on.
  set missionStatus to 6.
}

if(missionStatus = 6) {
  waitForTransferWindow().
  set missionStatus to 7.
}

if(missionStatus = 7) {
  doOrbitTransfer().
  set missionStatus to 8.
}
if(missionStatus = 8) {
  waitToEncounter(targetBody).
  set missionStatus to 9.
}
if(missionStatus = 9) {
  avoidCollision().
  set missionStatus to 10.
}
if(missionStatus = 10){
  lowerApoapsis().
}



