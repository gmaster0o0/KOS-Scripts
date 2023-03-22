runPath("../lib/vecDraw_lib.ks").
runPath("../lib/utils_lib.ks").
runPath("../lib/docking_lib.ks").

parameter nogodist is 50.

clearScreen.
clearVecDraws().



print "STATUS:" at (40,0).
print "Distance" at (40,1).
print "RelVel" at (40,2).
print "evadVec" at (40,3).

print "desiredFore:" at(40,10).
print "desiredTop :" at(40,11).
print "desiredStar:" at(40,12).
print "PIDfore:inp:" at(40,13).
print "PIDtop:inp :" at(40,14).
print "PIDstar:inp:" at(40,15). 
print "Direction  :" at(40,16).
print "PeriVel    :" at(40,17).

checkRelVel().
rcs ON.
evadeTarget(nogodist).

set target to selectTargetPort().
local dockingPort is getDockingPort().

goAround(target, dockingPort,nogodist).
approach(target, dockingPort,10).
killRelVelPrec().
local steer is selectPortRotation(target).
approach(target,dockingPort,0,steer).

//Finish docking.
sas off.
set ship:control:neutralize to true.
wait 5.
sas on.
rcs OFF.