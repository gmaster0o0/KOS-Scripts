runPath("../lib/ui_lib.ks").
runPath("../lib/staging_lib.ks").
runPath("../lib/launch_lib.ks").
runPath("../lib/landing_lib.ks").
runPath("../lib/rocket_utils_lib.ks").
runPath("../lib/hohhman_lib.ks").
runPath("../lib/warp_lib.ks").
runPath("../lib/wait_lib.ks").
runPath("../lib/utils_lib.ks").
runPath("../lib/node_lib.ks").
runPath("../lib/vecDraw_lib.ks").


local vecDrawLex is lexicon().
clearScreen.
clearVecDraws().
parameter orbitalName to "Duna".

if hasTarget {
  set orbitalName to target:name.
}

local phaseAngel is 0.
local ejectionAngle is 0.

local departureOrbitRadius is (ship:body:obt:apoapsis + ship:body:obt:periapsis)/2 + ship:body:body:radius.
print "departureOrbitRadius:   " + departureOrbitRadius.
local parkingOrbitRadius is ship:body:radius + ship:altitude.
print "parkingOrbitRadius:     " +  parkingOrbitRadius.
local arrivalOrbital is body(orbitalName).
local arrivalOrbitRadius is (arrivalOrbital:obt:apoapsis + arrivalOrbital:obt:periapsis)/2 + arrivalOrbital:body:radius.
print "arrivalOrbitRadius:     "+ arrivalOrbitRadius.

//local relativeAngle is calculateRelativeAngle().
local relativeAngle is getTargetAngle(ship:body,arrivalOrbital).
print "relativeAngle: " + relativeAngle.

set phaseAngel to 
  constant:pi*(1-((departureOrbitRadius+arrivalOrbitRadius)/(2*arrivalOrbitRadius))^1.5)
  * constant:RadToDeg.
print "phaseAngel: " + phaseAngel.

local arrivalOrbitalAngularVelocity is 360/arrivalOrbital:obt:period.
local currentAngularVelocity is 360 / ship:body:obt:period.

local angleChangeRate is abs(arrivalOrbitalAngularVelocity - currentAngularVelocity).
print "angleChangeRate: " + angleChangeRate.

local WaitDuration is utilReduceTo360(relativeAngle - phaseAngel)/angleChangeRate.
print time(WaitDuration):day + "Days " + time(WaitDuration):hour +"Hours "+ time(WaitDuration):second + "S".
local wtime is WaitDuration + time:seconds.
//kuniverse:timewarp:warpTo(time:seconds+WaitDuration).
//print mytime:calendar.
//local wtime is time:seconds.

local VecK is positionAt(ship:body,wtime) - positionAt(sun,wtime).
print VecK:mag.
local VecD is positionAt(target,wtime) - positionAt(sun,wtime).
print VecD:mag.
vecDrawAdd(vecDrawLex,positionAt(sun,wtime), vecK,cyan,"KPOS").
vecDrawAdd(vecDrawLex,positionAt(sun,wtime), vecD,red,"TPOS").



