runOncePath("../lib/landing2_lib.ks").
runOncePath("../lib/landVac_lib.ks",false).
runOncePath("../lib/vecDraw_lib.ks").

parameter landingTarget is getSelectedWaypoint().
parameter altitudeMargin is 50.

local vecDrawLex is lexicon().
clearScreen.

local commonLandingSpot is list(
  list("MunArch3Geo", "MUN", latlng(2.46390555,81.5258333))
).

local landingPos is getLandingPosition(landingTarget).
if landingPos:istype("boolean") and (not landingPos){
  print "INVALID LANDING TARGET".
}else{
  local calculatedPosition is "".

  for nodeItem in allnodes {
    remove nodeItem.
  }
  set landingPos to landingPos + landingPos:normalized * altitudeMargin.
  if status = "ORBITING" {
    set calculatedPosition to landAt(landingPos).
  }
  if status = "SUB_ORBITAL" {
    suicideburn().
  }

  clearVecDraws().
  local current is ship:body:geopositionof(ship:position).
  local targetPos is ship:body:geopositionof(landingPos).
  print "current=" + current.
  print "landing=" + targetPos.
  local distanceError is dist_between_coordinates(targetPos,current).
  print "distanceError=" + distanceError.

  vecDrawAdd(vecDrawLex, ship:position, landingPos+body:position, blue,"targetPos").

  if calculatedPosition <> "" {
    vecDrawAdd(vecDrawLex, ship:position, calculatedPosition+body:position, red,"landingPos").
  }
}

FUNCTION dist_between_coordinates { //returns the dist between p1 and p2 on the localBody, assumes perfect sphere with radius of the body + what ever gets passed in to atAlt
	PARAMETER p1,p2,atAlt IS 0.
	LOCAL localBody IS p1:BODY.
	LOCAL localBodyCirc IS CONSTANT:PI * (localBody:RADIUS + atAlt).//half the circumference of body
	LOCAL bodyPos IS localBody:POSITION.
	LOCAL bodyToP1Vec IS p1:POSITION - bodyPos.
	LOCAL bodyToP2Vec IS p2:POSITION - bodyPos.
	RETURN VANG(bodyToP1Vec,bodyToP2Vec) / 180 * localBodyCirc.
}

local function getSelectedWaypoint {
  for wp in allWaypoints() {
    if wp:isSelected(){
      return wp.
    }
  }
  return "".
}

local function getLandingPosition {
  parameter landingPosition.

  if landingPosition:istype("string"){
    set landingPosition to convertStingToType(landingPosition).
  }
  if landingPosition:istype("boolean") {
    return landingPosition.
  }

  if landingPosition:istype("vessel"){
    print "vessel=" + landingPosition.
    return landingPosition:position - body:position.
  }

  if landingPosition:istype("vector"){
    print "vector=" + landingPosition.
    return landingPosition - body:position.
  }

  if landingPosition:istype("waypoint"){
    print "waypoint=" + landingPosition.
    return landingPosition:position - body:position.
  }

  if landingPosition:istype("geocoordinates"){
    print "geocoordinates=" + landingPosition.
    return landingPosition:position - body:position.
  }
}

local function convertStingToType {
  parameter string.

  if string = "target" {
    if target:status = "landed" {
      return target.
    }
  }
  local coords is string:split(",").

  if coords:length = 2 {
    return latlng(coords[0],coords[1]).
  }

  if coords:length = 3 {
    return v(coords[0], coords[1], coords[2]).
  }

  for wp in allWaypoints() {
    if wp:body = ship:body {
      if string = wp:name {
        return wp.
      }.
    }
  }

  for spot in commonLandingSpot {
    if spot[1] = ship:body:name {
      if string = spot[0] {
        return spot[2].
      }
    }
  }
  
  return false.
}