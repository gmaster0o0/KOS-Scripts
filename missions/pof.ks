//interplanetary transfer POF

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

clearScreen.
clearVecDraws().

parameter orbitalName to "Duna".
parameter targetPE is 60000.

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
set EllipticalObtSMA to (departureOrbitRadius+arrivalOrbitRadius)/2.

set DepartureObtv to ship:body:obt:velocity:obt:mag.
set ParkingObtv to ship:obt:velocity:orbit:mag.
print "ParkingObtv:" + ParkingObtv.
set EllipticalObtv to sqrt(ship:body:body:mu*(2/departureOrbitRadius-1/EllipticalObtSMA)).
print "EllipticalObtv: " + EllipticalObtv.
set vInfinity to EllipticalObtv-DepartureObtv.

print "vInfinity: " + vInfinity.

set EscapeObtSMA to -ship:body:mu/vInfinity^2.
set EscapeObtv to sqrt(ship:body:mu*(2/parkingOrbitRadius-1/EscapeObtSMA)).

print "EscapeObtv: " + EscapeObtv.
set BurnDeltav to EscapeObtv-ParkingObtv.
print "BurnDeltav: " + BurnDeltav.

add node(time:seconds + WaitDuration,0,0,BurnDeltav).

local function calculateRelativeAngle {
  local angle is 0.
  if ship:body:name = "SUN" return 0.
  set angle to
    (
      arrivalOrbital:obt:longitudeofascendingnode
        +arrivalOrbital:obt:argumentofperiapsis
        +arrivalOrbital:obt:trueanomaly
    )
    -
      (
        ship:body:obt:longitudeofascendingnode
          +ship:body:obt:argumentofperiapsis
          +ship:body:obt:trueanomaly
      ).

  set angle to mod(angle,360).
  if angle < 0
    set angle to angle+360.
  return angle. 
} 