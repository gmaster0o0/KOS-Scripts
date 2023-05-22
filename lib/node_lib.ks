runOncePath("../lib/rocket_utils_lib.ks").
runOncePath("../lib/pid_lib.ks").
runOncePath("../lib/warp_lib.ks").

//NodeLib
//@Description: Manipulate and execute nodes
//TODO
global NodeLib is ({
  local autoWarp is true.

  local function setAutoWarp {
    parameter value.
    set autoWarp to value.
  }
  //remove all existing node
  local function removeNodes {
    if not hasNode return.
    for n in allNodes remove n.
    wait 0.
  }
  
  //Generate node from vector
  //@param {orbitable} vecTarget
  //@param {timespan} nodeTime
  //@param {body} localBody=ship:body
  local function nodeFromVector {
    parameter vecTarget,nodeTime,localBody IS ship:body.

    local vecNodePrograde IS (velocityAt(ship,nodeTime):orbit):normalized.
    local vecNodeNormal IS (vCrs(vecNodePrograde,positionAt(ship,nodeTime) - localBody:position)):normalized.
    local vecNodeRadial IS (vCrs(vecNodeNormal,vecNodePrograde)):normalized.
    
    local nodePrograde IS vDot(vecTarget,vecNodePrograde).
    local nodeNormal IS vDot(vecTarget,vecNodeNormal).
    local nodeRadial IS vDot(vecTarget,vecNodeRadial).

    return node(nodeTime,nodeRadial,nodeNormal,nodePrograde).
  }
  
  local function executeNode {
    parameter execNode is nextNode.
    parameter warpMargin is 60.
    parameter fineTune is false.

    
    lock throttle to 0.
    sas off.
    //Adjust the burnvector to the rotation
    local burnvector to getBodyRotation(execNode:time) * execNode:deltav.
    local burnTime to RocketUtils:burnTimeForDv(burnvector:mag).
    local burnStart to execNode:time - burnTime/2.
    burnDisplay().
    wait 0.
    local oldData is newOrbitData().
    rcs off.
    lock steering to lookdirup(getBodyRotation(execNode:time) * execNode:deltav, ship:facing:upvector).
    //now we need to wait until the burn vector and ship's facing are aligned
    printp("Ship aligning", 12).
    //wait until vang(ship:facing:vector, burnvector) < 0.25.
    printp("Wait for arriving", 12).
    //the ship is facing the right direction, let's wait for our burn time
    printO("NODE","Burn Starts: " + time(execNode:time - burnTime/2):full + "    ").
    if autoWarp{
      printp("Warping", 12).
      warpToNode(execNode, burnTime, warpMargin).
    }

    until abs(time:seconds - burnStart) < 0.01 {
      printp(round(burnvector:mag,3), 13).
      printp(round(execNode:deltav:mag,3), 14).
      printp(formatTime(burnTime), 15).
      printp(0, 16).
      printp(formatTime(execNode:eta - burnTime/2) ,17).
    }.
    local th to 0.
    lock throttle to th.
    local done is false.
    local errors is list(0.05,0.025).
    set burnvector to execNode:burnvector.
    until done  {
      
      printp("Burning        ", 12).
      set th to getThrottle(execNode:deltav:mag).
      if vdot(burnvector, execNode:deltav) < 0 {
        break.
      }

      if execNode:deltav:mag < min(errors[0], burnvector:mag/100) {
        wait until vdot(burnvector, execNode:deltav) < errors[1].
        set done to true.
      }
      checkBoosters().
      printp(round(burnvector:mag,3), 13).
      printp(round(execNode:deltav:mag,3), 14). 
      printp(formatTime(RocketUtils:burnTimeForDv(execNode:deltav:mag)), 15).
      printp(round(th*100,2), 16).
      printp("-" ,17).
    }
    lock throttle to 0.
    unlock all.
    set ship:control:pilotmainthrottle to 0.
    if execNode:deltav:mag < 5 {
      if fineTune {
        printp("Refining       ", 12).
        fineTuneManuever().
      }
      printp("Finished         ", 12).
    }else {
      printp("Execution error", 12).
    }

    local function newOrbitData {
      parameter theNode is nextNode.

      local orbitData is lexicon(
        "periapsis", theNode:orbit:periapsis,
        "apoapsis", theNode:orbit:apoapsis,
        "eccentricity", theNode:orbit:eccentricity,
        "argumentofperiapsis",theNode:orbit:argumentofperiapsis,
        "longitudeofascendingnode", theNode:orbit:longitudeofascendingnode,
        "inclination", theNode:orbit:inclination,
        "trajectoryData", calculateTrajectory(theNode:time + RocketUtils:burnTimeForDv(theNode:deltav:mag))
      ).

      return orbitData.
    }

    remove execNode.

    return oldData.
  }

  local function cancelVelocityError {
    parameter velocityError, stopCondition.

    local pidVector is pidLip:pidVector(60, 0.2, 0.2,-1,1). 
    pidVector:setpoint(v(0,0,0)).
    
    local shipControl is ship:control.

    until stopCondition() {
      local error is velocityError().
      printp(round(error:mag, 7), 18).
      set shipControl:translation to (-ship:facing) * pidVector:update(time:seconds, -error).
      wait 0.
    }

    set shipControl:translation to v(0,0,0).
  }

  local function fineTuneManuever {
    parameter maxError is 1e-3.

    if hasNode{
      local theNode to nextNode.
      local currentTime is time:seconds.
      local getVelocityError to {
        return theNode:deltav.
      }.
      local stopCondition to {
        return theNode:deltaV:mag < maxError or time:seconds > currentTime + 10.
      }.

      rcs on.
      sas on.
      cancelVelocityError(getVelocityError, stopCondition).
      rcs off.
    }
  }

  local function getThrottle {
    parameter dv.

    local maxAcc is ship:availablethrust/ship:mass.

    if ship:availableThrust = 0 {
      return 0.
    }

    return min(3*dv/maxAcc,1).
  }

  local function burnDisplay {
    print "============Node Burn===============" at (60,11).
    print "|STEP:                             |" at (60,12).
    print "|DV:                            m/s|" at (60,13).
    print "|DV LEFT:                       m/s|" at (60,14). 
    print "|BURN TIME:                        |" at (60,15).
    print "|THROTTLE:                        %|" at (60,16).
    print "|ETA:                             s|" at (60,17).
    print "|VelError:                      m/s|" at (60,18).
    print "====================================" at (60,19).
  }

  local function formatTime {
    parameter rawTime.

    local formatedTime is "".
    local hours is rawTime / 3600.
    if hours > 1 {
      set rawTime to mod(rawTime,3600).
      set formatedTime to formatedTime + floor(hours) + "h ".
    }
    local minutes is rawTime/60.
    if minutes > 1 {
      set rawTime to mod(rawTime,60).
      set formatedTime to formatedTime + floor(minutes) + "m ".
    }
    set formatedTime to formatedTime + round(rawTime,1) +"s".

    return formatedTime:padright(10).
  }

  local function printp {
    parameter str,line.
    print str:tostring:padright(15) at (72,line).
  }

  return lexicon(
    "setAutoWarp",setAutoWarp@,
    "nodeFromVector", nodeFromVector@,
    "removeAll", removeNodes@,
    "executeNode",executeNode@,
    "cancelVelocityError", cancelVelocityError@
  ).
}):call().