runPath("../lib/ui_lib.ks").
runPath("../lib/staging_lib.ks").
runPath("../lib/circ_lib.ks").
runPath("../lib/launch_lib.ks").
runPath("../lib/landing_lib.ks").
runPath("../lib/rocket_utils_lib.ks").
runPath("../lib/hohhman_lib.ks").
runPath("../lib/transfer_lib.ks").

parameter missionStatus is 0.
parameter targetApo is 80000.

//LAUNCH TO PARKING ORBIT.
run parkingOrbit().
set missionStatus to 5.
clearScreen.

print "========KERBINTOURS========".
print "targetAng:".
print "ETAofTransfer:".
print "angleChangeRate:".
print "========Event log========".

if(missionStatus = 5) {
  waitForTransferWindow().
  set missionStatus to 6.
}
if(missionStatus = 6) {
  doOrbitTransfer().
  set missionStatus to 7.
}
