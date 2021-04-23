local vecDrawLex is lex().

function vectorToAxis {
  parameter vec.
  
  local fore is VDOT(vec, ship:facing:forevector).
  local top is VDOT(vec, ship:facing:topvector).
  local star is VDOT(vec, ship:facing:starvector).

  return lexicon(
    "fore", fore,
    "top",top,
    "star", star
  ).
}

function portSelected {
  if hasTarget and target:istype("dockingport"){
    print "choose a matching size" at (60,0).
    return checkPortSize().
  }
}

function checkPortSize {
  local shipPort is ship:dockingports[0].
  return shipPort:nodetype = target:nodetype.
}

function checkRelVel {
  local relVelVec to getRelVelVec().
  if relVelVec:mag > 0.01 {
    killRelVelPrec().
  }
}

function getRelVelVec {
  local relVelVec is target:velocity:orbit - ship:velocity:orbit.
  print round(relVelVec:mag,3) at (60,2).
  return relVelVec.
}

function getDistanceVec {
  parameter offset is 0.
  parameter drawVec is true.

  local dockingPort is ship:dockingports[0].
  local targetPort is target:dockingports[0].
  local offsetVec is targetPort:portfacing:foreVector * offset.
  if drawVec {
    //vecDrawAdd(vecDrawLex, targetPort:position, offsetVec, cyan,"offsetVec").
  }
  local distanceVec is targetPort:nodePosition - dockingPort:nodePosition + offsetVec.
  if drawVec {
    vecDrawAdd(vecDrawLex, dockingPort:position, distanceVec, blue,"distanceVec").
  }
  print round(distanceVec:mag,1) at (60,1).
  return  distanceVec.
}

function getEvadeVec {
  parameter noGoZone is 100.
  parameter drawVec is true.

  local dockingPort is ship:dockingports[0].
  local evadeVec is getDistanceVec()- getDistanceVec(0,false):normalized * noGoZone.
  if drawVec {
    vecDrawAdd(vecDrawLex, dockingPort:position, evadeVec, blue,"evadeVec").
  }
  print evadeVec:mag at (60,3).

  return evadeVec.
}

function moveOnVec {
  parameter vec.

  LOCAL PIDfore IS PIDLOOP(4,0.1,0.01,-1,1).
  LOCAL PIDtop  IS PIDLOOP(4,0.1,0.01,-1,1).
  LOCAL PIDstar IS PIDLOOP(4,0.1,0.01,-1,1).

	SET PIDfore:SETPOINT TO vectorToAxis(vec)["fore"].
	SET PIDtop:SETPOINT TO vectorToAxis(vec)["top"].
	SET PIDstar:SETPOINT TO vectorToAxis(vec)["star"].

  local desiredFore TO PIDfore:UPDATE(TIME:SECONDS,vectorToAxis(getRelVelVec())["fore"]).
  local desiredTop TO PIDtop:UPDATE(TIME:SECONDS,vectorToAxis(getRelVelVec())["top"]) .
  local desiredStar TO PIDstar:UPDATE(TIME:SECONDS,vectorToAxis(getRelVelVec())["star"]).
      
  print round(desiredFore,1) + "   " at(60,10).
  print round(desiredTop,1) + "   " at(60,11).
  print round(desiredStar,1) + "   " at(60,12).
  print PIDfore:input at(60,13).
  print PIDtop:input at(60,14).
  print PIDstar:input at(60,15).
  
  set ship:control:fore to -desiredFore.
  set ship:control:top to -desiredTop.
  set ship:control:starboard to -desiredStar.
}

function approach {
  parameter targetPort is target:dockingports[0]. 
  parameter dockingPort is ship:dockingports[0].
  parameter offset is 0.

  print "approach         " at (60,0).
  dockingPort:controlFrom().
  lock steering to -1 * targetPort:portfacing:vector.
  until isCloseTo(offset,getDistanceVec(offset):mag){
    local approachVec is calcVelVecFromDistance(getDistanceVec(offset)).
    vecDrawAdd(vecDrawLex, dockingPort:position, approachVec, yellow,"approachVec").
    moveOnVec(-1*approachVec).
  }
  resetShipControl().
}

function killRelVelPrec {
  lock steering to target:position.
  print "Eliminate rel vel" at (60,0).
  UNTIL getRelVelVec():MAG < 0.05 {
    moveOnVec(-1*getRelVelVec()).
  }
  resetShipControl().
}

function evadeTarget {
  parameter noGoZone is 100.

  if getDistanceVec():mag > noGoZone{
    return.
  }
  local done is false.
  until done {
    print "Evade other ship    " at (60,0).
    local evadeVec is getEvadeVec(noGoZone).
    moveOnVec(-1*calcVelVecFromDistance(evadeVec)).

    set done to evadeVec:mag < 0.1.
  }
  killRelVelPrec().
}

function goAround{
  parameter targetPort is target:dockingports[0]. 
  parameter dockingPort is ship:dockingports[0].
  parameter noGoZone is 100.
  print "Go around         " at (60,0).
  local done is false.
  until done {
    local distanceVec is getDistanceVec().
    calcPerVel().
    local normVec is -1*vCrs(distanceVec:normalized,targetPort:facing:forevector):normalized.
    vecDrawAdd(vecDrawLex, dockingPort:position, normVec, red,"normVec").
    local periVec is vCrs(distanceVec,normVec):normalized * calcPerVel(noGoZone).
    vecDrawAdd(vecDrawLex, dockingPort:position, periVec, yellow,"periVec").
    vecDrawAdd(vecDrawLex, targetPort:position, (periVec - distanceVec):normalized * noGoZone - dockingPort:position, yellow,"periN").
    local moveVec is (periVec - distanceVec):normalized * noGoZone - dockingPort:position + distanceVec.
    vecDrawAdd(vecDrawLex, dockingPort:position, moveVec, green,"moveVec").
    local moveVelVec is calcVelVecFromDistance(moveVec).
    moveOnVec(-1* moveVelVec).

    local offsetVec is targetPort:portfacing:foreVector * noGoZone.
    vecDrawAdd(vecDrawLex, targetPort:position, offsetVec, cyan,"offsetVec").
    vecDrawAdd(vecDrawLex, dockingPort:position, distanceVec+offsetVec, magenta,"diffVec").
    set done to (distanceVec+offsetVec):mag < moveVelVec:mag.
  }
  killRelVelPrec().
}

function calcPerVel {
  parameter noGoZone is 100.
  parameter speedLimit is 5.
  local alpha is arcSin(speedLimit/noGoZone).
  local periVel is speedLimit / cos(alpha).
  print periVel at(60,17).
  return periVel.
}

function resetShipControl {
  set ship:control:fore to 0.
  set ship:control:top to 0.
  set ship:control:starboard to 0.
  clearVecDraws().
}

function calcVelVecFromDistance{
  parameter distanceVec.
  parameter speedLimit is 5.
  parameter acceleration is 1.

	local targetVel IS MIN(sqrt(2 * distanceVec:MAG / acceleration) * acceleration,speedLimit).
	return distanceVec:NORMALIZED * targetVel.
}
