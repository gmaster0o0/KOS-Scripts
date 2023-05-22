//TODO: rewrite to goto lib with parameters
//TODO: BUG: transfer have issue and starting the transfer burn after inclination burn.
//final orbit: flyby,eliptic,circular

runPath("../lib/ui_lib.ks").
runPath("../lib/staging_lib.ks").
runPath("../lib/launch_lib.ks").
runPath("../lib/landing_lib.ks").
runPath("../lib/rocket_utils_lib.ks").
runPath("../lib/hohhman_lib.ks").
runPath("../lib/transfer_lib.ks").
runPath("../lib/warp_lib.ks").
runPath("../lib/wait_lib.ks").
runPath("../lib/utils_lib.ks").
runPath("../lib/vecDraw_lib.ks").
//new type libs
runPath("../lib/node_lib.ks").
runPath("../lib/change_orbit_lib.ks").

parameter missionStatus is 0.
parameter autoWarp is false.

local orbitLib is ChangeOrbitLib(false,false).

local targetBody is MUN.

if hasTarget {
  set targetBody  to target.
}
local targetPE is targetBody:atm:height + 10000.

//LAUNCH TO PARKING ORBIT.
if status = "LANDED" or status = "PRELAUNCH" {
  run launch(missionStatus).
  set missionStatus to 5.
}
if status = "ORBITING" and targetBody <> body {
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
  local relInc is relativeIncAt(ship,targetBody).
  if (abs(relInc) > 0.01) {
    run changeinc.
  }
  
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
  avoidCollision(targetPE).
  set missionStatus to 10.
}
if(missionStatus = 10){
  //orbitLib:hyperbolicToElliptic().
  orbitLib:hyperbolicToCircular().
  nodeLib:executeNode(nextNode).
}



