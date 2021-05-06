local vecDrawLex is lexicon().

function isCloseTo {
	parameter targetNumber.
	parameter currentNumber.
	parameter threshold is 0.1.

	//print "threshold:  " + threshold + "      " at (5,24).
	//print "|" + round(targetNumber,3) + " - " + round(currentNumber,3) + "| < " + threshold at (5,25).
	return abs(targetNumber - currentNumber) < threshold.
}

function lngToDegrees {
  parameter lng.

  return mod(lng + 360, 360).
}

function getTargetAngle {
  return lngToDegrees(lngToDegrees(lngToDegrees(target:longitude) - lngToDegrees(ship:longitude))).
}

function utilReduceTo360 {
	parameter ang.
	return ang - 360 * floor(ang / 360).
}

function signAngle {
	parameter v1.
	parameter v2.
	parameter pn.
	return arcTan2(vDot(vCrs(v1,v2),pn),vDot(v1,v2)).
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
//normalVector of the orbit based on a object
function getNormalOfObjectOrbit {
	parameter object.

	local positionVector is object:body:position - object:position.
	local velocityVector is object:velocity:orbit.
	if object:status = "LANDED" {
		set velocityVector to object:velocity:surface.
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
function ETAtoTA {
	parameter orb.
	parameter ta.

	local currentTime is timeOfPEToTA(orb,orb:trueAnomaly).
	local taTime is timeOfPEToTA(orb,ta).
	return mod((taTime - currentTime) + orb:period,orb:period).
}
//relative inclination between 2 object
function relativeInc {
	parameter obj1.
	parameter obj2.

	local obj1Norm is getNormalOfObjectOrbit(obj1).
	local obj2Norm is getNormalOfObjectOrbit(obj2).

	return vang(obj1Norm,obj2Norm).
}
//true anomaly of AN node
function TAofANNode {
	parameter obj1.
	parameter obj2.

	local obj1Norm is getNormalOfObjectOrbit(obj1).
	local obj2Norm is getNormalOfObjectOrbit(obj2).

	local bodyToNodeVec is vcrs(obj1Norm,obj2Norm).
	local bodyToObjectVec is obj1:position - obj1:body:position.
	local angObjNode is vang(bodyToNodeVec,bodyToObjectVec).

	//passed the node
	if vdot(bodyToNodeVec, vCrs(obj1Norm,bodyToObjectVec):normalized) < 0 {
		set angObjNode to 360 - angObjNode.
	}

	return mod(angObjNode + obj1:orbit:trueAnomaly,360).
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
	local positionVector is object:body:position - positionAt(object,utime).
	local velocityVector is velocityAt(object,utime):orbit.
	vecDrawAdd(vecDrawLex,positionAt(object,utime),velocityVector*10000	,green,"V"+object:name).
	if object:status = "LANDED" {
		set velocityVector to velocityAt(object,utime):surface.
	}
	local normalVec is vCrs(velocityVector, positionVector):normalized.
	return normalVec.
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