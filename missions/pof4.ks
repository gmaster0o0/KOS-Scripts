clearScreen.

parameter orbitalName to "Duna".
parameter targetPE is 60000.

if hasTarget {
  set orbitalName to target:name.
}

local phaseAngel is 0.
local ejectionAngle is 0.

// dv1 = sqrt(mu/r1)*(sqrt(r2/sma)-1)
// dv2 = sqrt(mu/r2)*(1-sqrt(r1/sma))
// v = sqrt(mu/r)
// v1 = sqrt(2*mu(1/r1-1/r2)+v2^2)
// v_esc = sqrt(2*mu/r)
local departureOrbitalRadius is (ship:body:obt:apoapsis + ship:body:obt:periapsis)/2 + ship:body:body:radius.
print "departureOrbitalRadius:   " + departureOrbitalRadius.
local parkingOrbitRadius is ship:body:radius + ship:altitude.
print "parkingOrbitRadius:       " +  parkingOrbitRadius.
local arrivalOrbital is body(orbitalName).
local arrivalOrbitalRadius is (arrivalOrbital:obt:apoapsis + arrivalOrbital:obt:periapsis)/2 + arrivalOrbital:body:radius.

print "arrivalOrbitalRadius:     "+ arrivalOrbitalRadius.
print "v_esc :"  + sqrt(2*body:mu/parkingOrbitRadius).

local departureDV is sqrt(sun:mu/departureOrbitalRadius)*(sqrt(arrivalOrbitalRadius/((arrivalOrbitalRadius+departureOrbitalRadius)/2))-1).
print "departureDV: " + departureDV.

local captureDV is sqrt(sun:mu/arrivalOrbitalRadius)*(1-sqrt(departureOrbitalRadius/((arrivalOrbitalRadius+departureOrbitalRadius)/2))).
print "captureDV: " + captureDV.

local insertionDV is sqrt(2*body:mu*(1/parkingOrbitRadius-1/body:soiradius)+departureDV^2).
print "insertionDV: "+ insertionDV.

local ejectionDV is  insertionDV - sqrt(body:mu/parkingOrbitRadius).
print "ejectionDV: " + ejectionDV.
