runOncePath("../lib/rocket_utils_lib.ks").
runOncePath("../lib/pid_lib.ks").
runOncePath("../lib/warp_lib.ks").
runOncePath("../lib/utils_lib.ks").
runOncePath("../lib/ui_lib.ks").
runOncePath("../lib/staging_lib.ks").
runOncePath("../pof/rcs_lib.ks").

//NodeLib
//@Description: Manipulate and execute nodes
//TODO
global NodeLib is ({
  local autoWarp is false.

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
    parameter calculateTrajectoryData is false.

    
    lock throttle to 0.
    sas off.
    //Adjust the burnvector to the rotation
    local burnvector to getBodyRotation(execNode:time) * execNode:deltav.
    local totalBurnTime to RocketUtils:burnTimeForDv(burnvector:mag).
    local burnStart to execNode:time - RocketUtils:burnTimeForDv(burnvector:mag/2).

    wait 0.
    local delay is 0.
    if finetune {
      set delay to 10.
    }
    local oldData is newOrbitData(nextNode, burnStart + totalBurnTime + delay, calculateTrajectoryData).
    burnDisplay().
    lock steering to lookdirup(getBodyRotation(execNode:time) * execNode:deltav, ship:facing:upvector).
    //now we need to wait until the burn vector and ship's facing are aligned
    printp("Ship aligning       ", 12).
    //wait until vang(ship:facing:vector, burnvector) < 0.25.
    printp("Wait for arriving   ", 12).
    //the ship is facing the right direction, let's wait for our burn time
    printO("NODE","Burn Starts: " + time(execNode:time - totalBurnTime/2):full + "    ").
    if autoWarp{
      printp("Warping           ", 12).
      warpToNode(execNode, totalBurnTime, warpMargin).
    }

    until abs(time:seconds - burnStart) < 0.01 {
      printp(round(burnvector:mag,3), 13).
      printp(round(execNode:deltav:mag,3), 14).
      printp(formatTime(totalBurnTime), 15).
      printp(0, 16).
      printp(formatTime(burnStart - time:seconds) ,17).

    }.

    local startTime is time.
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
    local endTime is time.
    if execNode:deltav:mag < 5 {
      if fineTune {
        printp("Refining       ", 12).
        fineTuneManuever().
      }
      printp("Finished         ", 12).
    }else {
      printp("Execution error", 12).
    }
    
    printO("NODE","Burn ended. timeerror=: " + ((endTime - startTime) - totalBurnTime):seconds + "    ").
    remove execNode.

    
    return oldData.
  }

  local function newOrbitData {
    parameter theNode is nextNode.
    parameter startTime is nextNode:time + RocketUtils:burnTimeForDv(nextNode:burnvector:mag).
    parameter calculateTrajectoryData is false.

    local orbitData is lexicon(
      "periapsis", theNode:orbit:periapsis,
      "apoapsis", theNode:orbit:apoapsis,
      "eccentricity", theNode:orbit:eccentricity,
      "argumentofperiapsis",theNode:orbit:argumentofperiapsis,
      "longitudeofascendingnode", theNode:orbit:longitudeofascendingnode,
      "inclination", theNode:orbit:inclination
    ).
    if calculateTrajectoryData {
      orbitData:add("trajectoryData", calculateTrajectory(startTime + 2)).
    }

    return orbitData.
  }

  local function  executeNode2 {
    parameter execNode is nextNode.
    parameter warpMargin is 60.
    parameter fineTune is false.
    parameter calculateTrajectoryData is false.

    lock throttle to 0.
    sas off.
    local delay is 0.
    if finetune {
      set delay to 10.
    }
    
    local burnvector to getBodyRotation(execNode:time) * execNode:deltav.
    //3s minimum burning time for more accurate result
    //local burnTime to max(3,RocketUtils:burnTimeForDv(burnvector:mag)).
    local totalburnTime to RocketUtils:burnTimeForDv(burnvector:mag)*1.1.
    local burnStart to execNode:time - RocketUtils:burnTimeForDv(burnvector:mag/2) - 0.02.
    local burnEnd is burnStart + totalburnTime.
    local burnThrust to RocketUtils:thrustFromBurnTime(burnVector:mag, RocketUtils:getAvarageISP(), totalburnTime, ship:mass).
    local errors is list(0.05,0.025).
    local throttleLevel to min(1,burnThrust / ship:availablethrust).
    local oldData is newOrbitData(nextNode, burnEnd + delay, calculateTrajectoryData).
    lock steering to lookdirup(getBodyRotation(execNode:time) * execNode:deltav, ship:facing:upvector).
    burnDisplay().
    //now we need to wait until the burn vector and ship's facing are aligned
    printp("Ship aligning", 12).
    //wait until vang(ship:facing:vector, burnvector) < 0.25.
    printp("Wait for arriving", 12).
    //the ship is facing the right direction, let's wait for our burn time
    printO("NODE","Burn will start: " + time(burnStart):full + "    ").
    printO("NODE","Burn will ends: " + time(burnEnd):full + "    ").
    if autoWarp {
      printp("Warping          ", 12).
      warpToNode(execNode, totalburnTime, warpMargin).
    }

    until abs(burnStart - time:seconds) < 0.01 {
      printp(round(burnvector:mag,3), 13).
      printp(round(execNode:deltav:mag,3), 14).
      printp(formatTime(totalburnTime), 15).
      printp(round(throttleLevel*100,2) + "["+ round(burnThrust,2) + "/" + round(ship:availableThrust,1) +"]", 16).
      printp(formatTime(burnStart - time:seconds) ,17).
    }.

    //START BURNING
    local startTime is time.
    lock throttle to throttleLevel.
    local done is false.
    set burnvector to execNode:burnvector.
    until burnEnd - time:seconds  < 0.01 or done{
      checkBoosters().
      printp(round(burnvector:mag,3), 13).
      printp(round(execNode:deltav:mag,3), 14). 
      printp(formatTime(burnEnd - time:seconds), 15).
      printp(round(throttleLevel*100,2) + "["+ round(burnThrust,2) + "/" + round(ship:availableThrust,1) +"]", 16).
      printp("-" ,17).
      local dv is execNode:deltav:mag.
      local bt is RocketUtils:burnTimeForDv(dv).
      local tr to RocketUtils:thrustFromBurnTime(dv, RocketUtils:getAvarageISP(), burnEnd-time:seconds, ship:mass).

      log "bt=" + bt + "     tr=" + tr to "lofasz.log".

      //safety exit
      if vdot(burnvector, execNode:deltav) < 0 {
        print "SAFETY exit".
        break.
      }

      if execNode:deltav:mag < min(errors[0], burnvector:mag/100) {
        wait until vdot(burnvector, execNode:deltav) < errors[1].
        print "minError exit".
        set done to true.
        break.
      }
    }
    //Complete the execution
    lock throttle to 0.
    unlock all.
    set ship:control:pilotmainthrottle to 0.
    local endTime is time.
    if execNode:deltav:mag < 0.5 {
      if fineTune {
        printp("Refining       ", 12).
        fineTuneManuever().
      }
      printp("Finished         ", 12).
    }else {
      printp("ExecErr=" + round(execNode:deltav:mag,6), 12).
    }

    printO("NODE","Burn ended. error=: " + ((endTime - startTime) - totalburnTime):seconds + "    ").
    remove execNode.

    return oldData.
  }

  local function cancelVelocityError {
    parameter velocityError, stopCondition.

    local pidVector is pidLib:pidVector(1, 0.2, 0.2, -1, 1).

    local avgAxisThrusts is RCSLib:getAvarageThrustVector().
    local availableAxisAccs to avgAxisThrusts / ship:mass.

    local kis to 0.06  * availableAxisAccs.
    pidVector:setKI(kis).

    pidVector:setpoint(v(0,0,0)).
    rcsLib:setDeadband(0).

    local shipControl is ship:control.

    until stopCondition() {
      local error is velocityError().
      printp(round(error:mag, 7), 18).
      set shipControl:translation to (-ship:facing) * pidVector:update(time:seconds, -error).
      wait 0.
    }

    set shipControl:translation to v(0, 0, 0).
  }

  local function fineTuneManuever {
    parameter maxError is 1e-3.
    parameter refineDuration is 10.

    if hasNode{
      local theNode to nextNode.
      local currentTime is time:seconds.
      local getVelocityError to {
        return theNode:deltav.
      }.
      local stopCondition to {
        return theNode:deltaV:mag < maxError or time:seconds > currentTime + refineDuration.
      }.

      rcs on.
      sas on.
      cancelVelocityError(getVelocityError, stopCondition).
      rcs off.
    }
  }

  local function getThrottle {
    parameter dv.

    //TODO need to figure out what is this number.

    local shipAcc is ship:availablethrust/ship:mass.

    if ship:availableThrust = 0 {
      return 0.
    }

    return min( 3.7 * dv / shipAcc,1).
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
    set formatedTime to formatedTime + round(rawTime,2) +"s".

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
    "executeNode2", executeNode2@,
    "cancelVelocityError", cancelVelocityError@
  ).
}):call().