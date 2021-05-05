//return with free docking ports list for every size
function getFreeDockingPorts {
  parameter craft.

  local ports is lex().
  for d in craft:dockingPorts {
    if d:state = "ready" {
      if ports:keys:contains(d:nodeType) {
        ports[d:nodeType]:add(d).
      }else{
        ports:add(d:nodeType,list(d)).
      }
    }
  }
  return ports.
}

function getTargetCraft {
  if target:istype("dockingport"){
    return target:ship.
  }
  return target.
}

//return with open docking ports which have same size
function matchingDockingPorts {
  local shipPorts is getFreeDockingPorts(ship).
  local targetPorts is getFreeDockingPorts(getTargetCraft()).

  local matchingPorts is lex().
  for k in shipPorts:keys {
    if targetPorts:keys:contains(k){
      if matchingPorts:keys:contains(k){
        matchingPorts[k]:add(targetPorts[k]).
      }else{
        matchingPorts:add(k,targetPorts[k]).
      }
    }
  }

  return matchingPorts.
}
//return with the selected dockingport
function selectTargetPort {

  if hasTarget{
    if target:istype("vessel"){
      return chooseTargetPort().
    }
    if target:istype("dockingport"){
      return target.
    }
    unset target.
    return.
  }
}
//default dockingport
//selected with "control from here"
//or from matching docking ports
//first size first docking port is the default.
function getDockingPort {
  parameter size is "default".
  if ship:controlPart:isType("dockingport"){
    return ship:controlPart.
  }
  if size = "default" {
    set size to matchingDockingPorts():keys[0].
  }
  return getFreeDockingPorts(ship)[size][0].
}

function compatiblePorts {
  local dockingPortSize is getDockingPort():nodetype.
  return  matchingDockingPorts()[dockingPortSize].
}

function chooseTargetPort {
  local targetPorts is compatiblePorts().
  if targetPorts:length = 1 {
    return targetPorts[0].
  }
  clearscreen.
  print "Choose docking port".
  print "RCS=next".
  print "abort=finish".
  local selectedPort is targetPorts[0].
  local counter is 0.
  until abort {
    if rcs {
      set counter to mod(counter + 1, targetPorts:length).
      set selectedPort to targetPorts[counter].
      set target to selectedPort.
      print "["+counter+"]"+selectedPort.
      rcs off.
    }
  }
  rcs off.
  abort off.
  return selectedPort.
}

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

function checkRelVel {
  local relVelVec to getRelVelVec().
  if relVelVec:mag > 0.01 {
    killRelVelPrec().
  }
}

function getRelVelVec {
  local targetCraft is getTargetCraft().

  local relVelVec is targetCraft:velocity:orbit - ship:velocity:orbit.
  print round(relVelVec:mag,3) at (60,2).
  return relVelVec.
}

function getDistanceVec {
  parameter offset is 0.
  parameter drawVec is true.

  local dockingPort is getDockingPort().

  local distanceVec is v(0,0,0).

  if target:istype("dockingport"){
    local targetPort is target.
    local offsetVec is targetPort:portfacing:foreVector * offset.
    set distanceVec to targetPort:nodePosition - dockingPort:nodePosition + offsetVec.
  }else{
    local offsetVec is (target:position - dockingPort:nodePosition):normalized * offset.
    set distanceVec to target:position - dockingPort:nodePosition + offsetVec.
  }

  
  if drawVec {
    vecDrawAdd(vecDrawLex, dockingPort:position, distanceVec, blue,"distanceVec").
  }
  print round(distanceVec:mag,1) at (60,1).
  return  distanceVec.
}

function getEvadeVec {
  parameter noGoZone is 100.
  parameter drawVec is true.

  local dockingPort is getDockingPort().
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
  parameter targetPort is target. 
  parameter dockingPort is getDockingPort().
  parameter offset is 0.
  parameter steer is -1 * targetPort:portfacing:vector.

  print "approach         " at (60,0).
  dockingPort:controlFrom().
  lock steering to steer.
  until isCloseTo(offset,getDistanceVec(offset):mag){
    local approachVec is calcVelVecFromDistance(getDistanceVec(offset),2).
    vecDrawAdd(vecDrawLex, dockingPort:position, approachVec, yellow,"approachVec").
    moveOnVec(-1*approachVec).
  }
  resetShipControl().
}

function killRelVelPrec {
  lock steering to target:position.
  print "Eliminate rel vel" at (60,0).
  UNTIL getRelVelVec():MAG < 0.01 {
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
    //vecDrawAdd(vecDrawLex, dockingPort:position, normVec, red,"normVec").
    local periVec is vCrs(distanceVec,normVec):normalized * calcPerVel(noGoZone).
    //vecDrawAdd(vecDrawLex, dockingPort:position, periVec, yellow,"periVec").
    vecDrawAdd(vecDrawLex, targetPort:position, (periVec - distanceVec):normalized * noGoZone - dockingPort:position, yellow,"periN").
    local moveVec is (periVec - distanceVec):normalized * noGoZone - dockingPort:position + distanceVec.
    vecDrawAdd(vecDrawLex, dockingPort:position, moveVec, green,"moveVec").
    local moveVelVec is calcVelVecFromDistance(moveVec).
    moveOnVec(-1* moveVelVec).

    local offsetVec is targetPort:portfacing:foreVector * noGoZone.
    vecDrawAdd(vecDrawLex, targetPort:position, offsetVec, cyan,"offsetVec").
    vecDrawAdd(vecDrawLex, dockingPort:position, distanceVec+offsetVec, magenta,"diffVec").
    print (distanceVec+offsetVec):mag at (30,30).
    print (moveVec):mag at (30,31).
    set done to (distanceVec+offsetVec):mag < 2 * moveVec:mag.
  }
  killRelVelPrec().
}

function calcPerVel {
  parameter noGoZone is 100.
  parameter speedLimit is 5.
  local alpha is arcSin(speedLimit/noGoZone).
  local periVel is speedLimit / cos(alpha).
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
  //TODO Asume RCS thrust 1kN
  parameter acceleration is 1/ship:mass.

	local targetVel IS MIN(sqrt(2 * distanceVec:MAG / acceleration) * acceleration,speedLimit).
	return distanceVec:NORMALIZED * targetVel.
}

function selectPortRotation{
  parameter targetPort is target:dockingports[0]. 

  clearscreen.
  print "Choose port rotation".
  print "SAS=Rotate 90".
  print "abort=Confrim".
  rcs on.
  local portRotation is 0.
  local targetFore is targetPort:portFacing:foreVector.
  local targetTop is targetPort:portFacing:topVector.
  local steer is angleAxis(portRotation, targetFore) * lookDirUp(-targetFore,targetTop).
  until abort {
    lock steering to steer.
    wait until steeringManager:angleerror < 1.
    if sas {
      set portRotation to utilReduceTo360(portRotation + 90).
      print "selected port rotation:" + portRotation.
      sas off.
      set steer to angleAxis(portRotation, targetFore) * lookDirUp(-targetFore,targetTop).
    }
  }
  sas off.
  abort off.

  return steer.
}