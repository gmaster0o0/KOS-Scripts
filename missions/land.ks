runOncePath("../lib/landing2_lib.ks").
runOncePath("../lib/landVac_lib.ks",false).
runOncePath("../lib/vecDraw_lib.ks").

//parameter landingTarget is getDefaultLanding().
parameter landingTarget is "MunArch3Geo".
parameter altitudeMargin is 5.

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
  local finishedPos is ship:position - body:position.
  if status = "SUB_ORBITAL" {
    suicideburn().
  }

  clearVecDraws().
  local current is ship:body:geopositionof(ship:position).
  local targetPos is ship:body:geopositionof(landingPos).
  print "current=" + current.
  print "landing=" + targetPos.
  local distanceError is getSurfaceDistance(landingPos, ship:position-body:position).
  print "distanceError=" + distanceError.

  vecDrawAdd(vecDrawLex, ship:position, landingPos+body:position, blue,"targetPos").

  if calculatedPosition <> "" {
    vecDrawAdd(vecDrawLex, ship:position, calculatedPosition+body:position, red,"landingPos").
  }

  vecDrawAdd(vecDrawLex, ship:position, finishedPos+body:position, green,"finishedPos").


}

local function getDefaultLanding {
  if hasTarget and target:istype("VESSEL") and target:status = "LANDED" {
    return target.
  }

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