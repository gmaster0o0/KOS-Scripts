runPath("../lib/vecDraw_lib.ks").
runPath("../lib/utils_lib.ks").
runPath("../lib/docking_lib.ks").

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

RCS ON.
checkRelVel().
evadeTarget(100).
goAround(target:dockingports[0], ship:dockingports[0],100).
approach(target:dockingports[0], ship:dockingports[0]).
SET SHIP:CONTROL:NEUTRALIZE TO TRUE.
WAIT 5.
RCS OFF.