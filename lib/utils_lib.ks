//Math and util functions

local vecDrawLex is lexicon().

function isCloseTo {
  parameter targetNumber.
  parameter currentNumber.
  parameter threshold is 0.1.

  //print "threshold:  " + threshold + "      " at (5,24).
  //print "|" + round(targetNumber,3) + " - " + round(currentNumber,3) + "| < " + threshold at (5,25).
  return abs(targetNumber - currentNumber) < threshold.
}
// convert the (-180,+180) to (0,360)
function lngToDegrees {
  parameter lng.

  return mod(lng + 360, 360).
}

function getTargetAngle {
  parameter obj1 is ship.
  parameter obj2 is target.
  return lngToDegrees(lngToDegrees(lngToDegrees(obj2:longitude) - lngToDegrees(obj1:longitude))).
}

function utilReduceTo360 {
  parameter ang.
  return ang - 360 * floor(ang / 360).
}

//v1 - Vector
//v2 - vector
function signAngle {
  parameter v1.
  parameter v2.
  parameter pn is vCrs(v1:normalized,v2:normalized):normalized.
  return arcTan2(vDot(vCrs(v2,v1),pn),vDot(v1,v2)).
}

//calc gravity over altitude
function gravity {
  parameter h is altitude.
  return body:mu / (body:radius + h) ^ 2.
}
//calc max acceleration over altitude
function maxAccUp {
  parameter h is altitude.

  local shipMaxAcceleration is ship:availablethrust / ship:mass.
  return shipMaxAcceleration - (gravity(0) + gravity(h)).
}
//calc avarage gravity between 2 point
function avgGrav {
  parameter startAlt is altitude.
  parameter dist is altitude.

  return (gravity(startAlt) + gravity(startAlt - dist))/2.
}
//get the rotation of the ship around the body in given timeframe
function getShipOrbitalRotationAroundBody {       
  parameter UT is time:seconds + 10.

  local pos to (positionat(ship, UT) - body:position).
  local vel to (velocityat(ship, UT):orbit).

  return lookdirup(vel, vcrs(vel, pos)).
}

//get body rotation between two time.
// return with direction
function getBodyRotation {
    parameter endTime, startTime is time:seconds.

    return -angleaxis(constant:radtodeg * body:angularvel:mag * (endTime - startTime), body:angularvel:normalized).
}

//Eccentricity anomaly from true anomaly
//https://en.wikipedia.org/wiki/Eccentric_anomaly
function EAFromTA {
  parameter ecc.
  parameter ta.

  return arcTan2( sqrt(1 - ecc^2) * sin(ta), ecc + cos(ta)).
}
//mean anomaly from true anomaly
//https://en.wikipedia.org/wiki/Mean_anomaly
function MAFromTA {
  parameter ecc.
  parameter ta.

  local EA is EAFromTA(ecc,ta).
  local MA IS EA - (ecc * sin(EA) * CONSTANT:RADtoDEG).
  
  return lngToDegrees(MA).
}

function getTrueAnomalyAt{
  parameter orbitable, universalTime.

  local positionVector IS positionAt(orbitable,universalTime) - orbitable:body:position.

  local TA IS getTrueAnomaly(orbit:semimajoraxis,orbit:eccentricity,positionVector:mag).

  if positionAt(orbitable,universalTime+1):mag < positionVector:mag {
    return 360 - TA.
  }

  return TA.
}

//calculate the true anomaly
//r = a*(1-e*e)/1+e*cosV
//rearrange => cosV = (a*(1-e*e)-r)/(e*r)
function getTrueAnomaly{
  parameter sma, ecc, radius.
  // print sma.
  // print ecc.
  // print radius.

  return arcCos( ((sma * (1 - ecc^2)) - radius)/ (ecc * radius)).
}

//normalVector of the orbit based on a object
function getNormalOfObjectOrbit {
  parameter object.

  local positionVector is object:body:position - object:position.
  local velocityVector is object:velocity:orbit.
  if object:istype("vessel"){
    if object:status = "LANDED" {
      set velocityVector to object:velocity:surface.
    }
  }
  local normalVec is vCrs(velocityVector, positionVector):normalized.
  return normalVec.
}
//time from periapsis to true anomaly
function timeOfPEToTA {
  parameter orb.
  parameter ta.

  local ecc is orb:eccentricity.
  local period is orb:period.
  local MA is MAFromTA(ecc,ta).

  return (MA/360) * period.
}
//ETA to a given true anomaly
//TODO add default orbit and refractor all code
function ETAtoTA {
  parameter orb.
  parameter ta.

  local currentTime is timeOfPEToTA(orb,orb:trueAnomaly).
  local taTime is timeOfPEToTA(orb,ta).
  return mod((taTime - currentTime) + orb:period,orb:period).
}
//relative inclination between 2 object
function relativeIncAt {
  parameter obj1.
  parameter obj2.
  parameter utime is time:seconds.

  local obj1Norm is getNormalOfObjectOrbitAt(obj1,utime).
  local obj2Norm is getNormalOfObjectOrbitAt(obj2,utime).

  return vang(obj1Norm,obj2Norm).
}

function orbitalPositionVector {
  parameter orbitable is ship.
  parameter utime is time:seconds.
  parameter parentOrbitable is orbitable:body.

  return positionAt(orbitable,utime) - parentOrbitable:position.
}

//TODO TAofDNNODE
//TODO craft and craft's orbit
//true anomaly of AN node
//param obj1: craft
//param obj2: craft or body
//param obj1TA: true anomaly of obj1
function TAofANNode {
  parameter obj1.
  parameter obj2.
  parameter obj1TA is obj1:orbit:trueAnomaly.

  local obj1Norm is getNormalOfObjectOrbit(obj1).
  local obj2Norm is getNormalOfObjectOrbit(obj2).

  local bodyToNodeVec is vcrs(obj1Norm,obj2Norm).
  local bodyToObjectVec is obj1:position - obj1:body:position.
  local angObjNode is vang(bodyToNodeVec,bodyToObjectVec).

  //passed the node
  if vdot(bodyToNodeVec, vCrs(obj1Norm,bodyToObjectVec):normalized) < 0 {
    set angObjNode to 360 - angObjNode.
  }

  return mod(angObjNode + obj1TA,360).
}

function getBurnVector {
  parameter obj1.
  parameter obj2.
  parameter timeToNode.

  local velAtAN is velocityAt(ship, timeToNode + time:seconds):orbit.
  local sNorm is getNormalOfObjectOrbit(obj1).
  local tNorm is getNormalOfObjectOrbit(obj2).

  //vecDrawAdd(vecDrawLex,ship:position,ship:velocity:orbit,RED,"svel").
  //vecDrawAdd(vecDrawLex,ship:position,minmus:velocity:orbit,BLUE,"tvel").
  //vecDrawAdd(vecDrawLex,ship:position,sNorm*10000,yellow,"sNorm").
  
  local burn_unit is (sNorm + tNorm ):NORMALIZED.
  local burn_mag is sNorm*velAtAN - tNorm*velAtAN.
  local burnVector is burn_mag*burn_unit.
  //vecDrawAdd(vecDrawLex,ship:position,burnVector,green,"burnVector").

  return burnVector.
}

function getNormalOfObjectOrbitAt {
  parameter object.
  parameter utime is time:seconds.
  
  //print object.
  local positionVector is object:body:position - positionAt(object,utime).
  local velocityVector is velocityAt(object,utime):orbit.
  //vecDrawAdd(vecDrawLex,positionAt(object,utime),positionVector*-1	,blue,"P"+object:name).
  if object:istype("vessel"){
    if object:status = "LANDED" {
      set velocityVector to velocityAt(object,utime):surface.
    }
  }
  //vecDrawAdd(vecDrawLex,positionAt(object,utime),velocityVector*1000	,green,"V"+object:name).
  local normalVec is vCrs(velocityVector, positionVector):normalized.

  return normalVec.
}

function getOrbitalPeriod {
  parameter semiMajorAxis is obt:semimajoraxis.
  parameter centerBody is body.

  return 2 * constant:pi * sqrt(semiMajorAxis^3 / centerBody:mu).
}
//Get ETA for the given altitude of the given orbit.
//only eliptical orbit
//TODO hyperbolic orbit too.
function ETAtoAltitude {
  parameter targetOrbit, referenceTrueAnomaly, targetAltitude is 0.

  set targetAltitude to targetAltitude + targetOrbit:body:radius.
  if targetOrbit:eccentricity <=1 {
    //r = a * (1-e^2/(1+e*cosv)) -> v = arccos(a*(1-e^2)-r)/e*r)
    //get the true anomaly where the vessel reach the target altitude
    //print round((targetOrbit:semimajoraxis * (1 - targetOrbit:eccentricity^2) - targetAltitude) / (targetOrbit:eccentricity * targetAltitude),5).
    //print (targetOrbit:eccentricity * targetAltitude).
    //print(targetOrbit:semimajoraxis * (1 - targetOrbit:eccentricity^2) - targetAltitude).

    local altitudeTrueAnomaly to arccos(round((targetOrbit:semimajoraxis * (1 - targetOrbit:eccentricity^2) - targetAltitude) / (targetOrbit:eccentricity * targetAltitude),5)).
    set altitudeTrueAnomaly to 360 - altitudeTrueAnomaly.
    return timeBetweenTrueAnomalies(referenceTrueAnomaly, altitudeTrueAnomaly, targetOrbit:eccentricity, targetOrbit:period).
  }

  return 0.
}

function timeBetweenTrueAnomalies {
  parameter TA1, TA2, eccentricity, period.

  local meanAnomaly1 is MAFromTA(eccentricity,TA1).
  local meanAnomaly2 is MAFromTA(eccentricity,TA2).

  return (lngToDegrees(meanAnomaly2-meanAnomaly1)/360) * period.
}

function perimeterPerDegreee {
  parameter targetBody is body.

  return (2 * constant:pi * targetBody:radius)/360.
}

//Get eccentricity vector for a vector
//reference: https://en.wikipedia.org/wiki/Eccentricity_vector
function getEccentricityVectorAt{
  parameter orbitable is ship.
  parameter utime is time:seconds.
  
  local velocityVector is velocityAt(orbitable,utime):orbit.
  local positionVector is positionAt(orbitable,utime)-orbitable:body:position.
  local mu is orbitable:body:mu.

  return (velocityVector:mag^2/mu -1/positionVector:mag)*positionVector - vdot(positionVector,velocityVector)/mu*velocityVector.
}

function getTrueAnomalyOfVector {
  parameter positionVector is orbitalPositionVector().
  parameter velocityVector is ship:velocity:orbit.
  parameter eccentricityVector is getEccentricityVectorAt().

  local TA is arcCos(eccentricityVector*positionVector/(positionVector:mag * eccentricityVector:mag)).
.
  if positionVector * velocityVector < 0 and getOrbitDirection() > 0  {
    return 360 - TA.
  }

  return TA.
}
//calculate the orbit direction
//return +1 if orbit is prograde
//return -1 if orbit is retrograde
function getOrbitDirection {
  parameter positionVector is orbitalPositionVector().
  parameter velocityVector is ship:velocity:orbit.
  parameter eccentricityVector is getEccentricityVectorAt().

  return sign(signAngle(vCrs(velocityVector,positionVector),eccentricityVector)).
}
//calculate the ETA of DN or AN and returnin the direction
//function for inclination change
function getClosestNodeETA {
  parameter targetOrbit is orbit.

  local ETAtoDN to ETAtoTA(targetOrbit, 180-targetOrbit:argumentofperiapsis).
  local ETAtoAN to ETAtoTA(targetOrbit, 360-targetOrbit:argumentofperiapsis).
  if (ETAtoAN > ETAtoDN) {
    return lexicon(
      "direction",-1,
      "eta", ETAtoDN
    ).
  }
    return lexicon(
      "direction",1,
      "eta", ETAtoAN
    ).
}

function sign {
  parameter value.
  
  return value/abs(value).
}