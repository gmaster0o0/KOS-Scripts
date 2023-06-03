//Precisious landing libary at vacuum.
//Know issues:
//TODO deorbit hill climb sometimes stuck
//Some miss calculation, somewhere. Same amount of landing error
//LIMITATIONS: - parking orbit should be close to circular orbit.
//             -Multi staging not tested, and probably wont work



runPath("../lib/ui_lib.ks").
runPath("../lib/staging_lib.ks").
runOncePath("../lib/rocket_utils_lib.ks").
runOncePath("../lib/hohhman_lib.ks").
runPath("../lib/warp_lib.ks").
runPath("../lib/wait_lib.ks").
runPath("../lib/utils_lib.ks").
runOncePath("../lib/node_lib.ks").
runPath("../lib/vecDraw_lib.ks").
runOncePath("../lib/hillClimb_lib.ks").
runOncePath("../lib/simulation_lib.ks").
runOncePath("../lib/interpolation_lib.ks").
runOncePath("../lib/time_lib.ks").

runOncePath("../pof/deorbit.ks").

local vecDrawLex is lexicon().

function refineLandingPosition {
  parameter landingPosition.
  parameter landingStartTime is 5644836.

  local landingProgressUpdater to {
    parameter landingSimInfo.
    progressUpdater(lex("landingSimInfo", landingSimInfo)).
  }.
  local deltaTimeList to list(1, 0.6, 0.1, 0.04).
  local getPosVelAtTime to getPosVelAtTimeFromOrbit().
  local getPositionError to {
      parameter simPos.
      return simPos:mag - landingPosition:mag.
  }.

  local function getPosVelAtTimeFromOrbit {
    return {
      parameter simTime.
      local fixRot to getBodyRotation(simTime).
      return list(fixRot * (positionat(ship, simTime) - body:position),
                  fixRot * (velocityat(ship, simTime):surface)).
    }.
  }
  local landingData is lex("landingError",v(1000,1000,1000)).

  local calculateLandingData is {
    set landingData to calculateLandingBurn(landingStartTime, ship:availablethrust, RocketUtils:getAvarageISP(), ship:mass, deltaTimeList, 1,
                                              getPosVelAtTime, getPositionError, landingProgressUpdater).
    landingData:add("landingError", landingData:landingPosition - landingPosition).

    return landingData.
  }.

  local stopCondition is {
    return (landingData:landingError:mag < 1) or (not rcs).
  }.

  cancelLandingError(calculateLandingData, stopCondition).

  return landingData.
}

function landAt {
  parameter landingPosition.
  //drawArrowTo(vecDrawLex,targetPosition,blue,"targetPos").
  local deOrbitData is createDeOrbitNode(landingPosition).
  local landingSimResult is calculateLanding(landingPosition, deOrbitData).
  //local trajectoryData is calculateTrajectory(landingSimResult:deorbitData:endTime+1,120).
  //print landingSimResult.
  nodeLib:setAutoWarp(true).
  local nodeExecutionResult is NodeLib:executeNode(nextNode, 30, false, true).
  print "burnTimeError=" + (landingSimResult:deorbitData:endTime - time:seconds).
  local orbitData is lexicon(
    "periapsis", ship:orbit:periapsis,
    "apoapsis", ship:orbit:apoapsis,
    "eccentricity", ship:orbit:eccentricity,
    "argumentofperiapsis",ship:orbit:argumentofperiapsis,
    "longitudeofascendingnode", ship:orbit:longitudeofascendingnode,
    "inclination", ship:orbit:inclination,
    "trajectoryData", calculateTrajectory(landingSimResult:deorbitData:startTime + 10)
  ).

  // for key in orbitData:keys {
  //   if key <> "trajectoryData" {
  //     print key + ": " + (nodeExecutionResult[key] - orbitData[key]).
  //   }
  // }
  //refineOrbit(nodeExecutionResult:trajectoryData).
  set landingSimResult:landingData to refineLandingPosition(landingPosition, landingSimResult:landingData:burnStartTime).

  set navMode to "SURFACE".
  sas on.
  wait 0.
  set sasMode to "RETROGRADE".
  print "Landing will start at " + time(landingSimResult:landingData:burnStartTime):clock.
  warpto(landingSimResult:landingData:burnStartTime - 30).
  wait until abs(landingSimResult:landingData:burnStartTime - 0.02 - time:seconds) < 0.01.
  lock throttle to 1.
  wait until abs(landingSimResult:landingData:burnEndTime - time:seconds) < 0.01.
  unlock throttle.
  sas off.

  //print "position error=" + (positionAt(ship,time) - body:position - landingSimResult:landingData:landingPosition):mag.
  //print "velocity error=" + velocityAt(ship,time):surface:mag.
  //writeJson(landingSimResult, "landingdata.json").

  return landingSimResult:landingData:landingPosition.
}

//TODO check why timeouting
local function createDeOrbitNode2 {
  parameter targetPosition.

  //Adjust the nodeUT.
  local targetProjection is vxcl(vCrs(body:position, velocity:orbit):normalized,targetPosition).
  local projectionTrueAnomaly is getTrueAnomalyOfVector(targetProjection,ship:velocity:orbit,getEccentricityVectorAt()).

  local nodeUT to time:seconds + ETAtoTA(ship:orbit,projectionTrueAnomaly-180).

  //stepsize, threshold, minstepsize, minThreshold, , errorMargin
  local settingsList is list(
    list(ship:orbit:period/4, 32, 32, 1, 1000),
    list(ship:orbit:period/8, 16, 16, 0.5,  500)
    //list(ship:orbit:period/32, 8, 8, 0.1, 200)
  ).

  // local settingsList is list(
  //   list(ship:orbit:period/3, 10, 10, 0.1, 500)
  // ).


  local intersectAltitude to targetPosition:mag - body:radius. 
  //local targetPE is targetPosition:mag - 2 * body:radius.
  local targetPE is  body:radius / -1.5.
  local initDV is getInitDeorbitDV(nodeUT, targetPE).
  local deorbitNode to node(nodeUT, 0, 0, initDV).
  add deorbitNode.
  
  local getDistanceError is {
    parameter v1.
  
    set deorbitNode:time to v1:x.
    set deorbitNode:normal to v1:y.
    set deorbitNode:prograde to v1:z.
  
    local dist is ship:body:radius * constant:pi.
    //local intersectAltitude to targetPosition:mag - body:radius.

    if deorbitNode:orbit:periapsis <= intersectAltitude {
      local intersectTime is deorbitNode:time + ETAtoAltitude(deorbitNode:orbit, 180, intersectAltitude).
      local impactPosition to getBodyRotation(intersectTime) * (positionat(ship, intersectTime) - body:position).
      
      set dist to getSurfaceDistance(targetPosition, impactPosition).
    }

    return dist.
  }.

  local progressUpgrader is {
    parameter progressData.
    print "=============DEORBIT SIM=============" at (60,2).
    print "|Steps=" + progressData:steps at (60,3).
    print "|minimum=" + round(progressData:minimum,3) at (60,4).
    print "|stepSize=" + round(progressData:stepSize,3) at (60,5).
    print "|threshold=" + round(progressData:threshold,3) at (60,6).
    print "|settingsIndex=" + progressData:settingsIndex at (60,7).
    print "=====================================" at (60,8).
  }.
  
  local result is calculateDeorbitNode(deorbitNode, settingsList, getDistanceError, progressUpgrader).
    
  //refresh the result. It can be different from the actual node if the calculation timeouted.
  set deorbitNode:time to result:position:x.
  set deorbitNode:prograde to result:position:z.
  set deorbitNode:normal to result:position:y.

  // return lex(
  //   "nodeUT", result:position:x,
  //   "nodeDV", v(0,result:position:y,result:position:z)
  // ).
  return lex("deorbitNode",deorbitNode).
}

local function calculateLanding {
  parameter landingPosition, deorbitData.

  local intersectAltitude to landingPosition:mag - body:radius.
  local intersectTime is deorbitData:deorbitNode:time + ETAtoAltitude(deorbitData:deorbitNode:orbit, 180,intersectAltitude).

  local engineISP is RocketUtils:getAvarageISP().
  local shipThrust is ship:availableThrust.
  // errorMargin, burnMinDt, burnMaxDt, landingMinDtList, maxLandingAltitudeError
  local settingsList to list(
    list(500, 0.02, 0.06, list(1, 0.6), 5),
    //list(200, 0.02, 0.06, list(1, 0.6), 1),
    list(5, 0.02, 0.02, list(1, 0.6, 0.1), 1)
  ).
  local settingsIndex to 0.
  local settings to settingsList[settingsIndex].
  
  local simStartTime is 0.
  local loopCount is 0.

  local landingProgressUpdater to {
    parameter landingSimInfo.
    progressUpdater(lex("landingSimInfo", landingSimInfo)).
  }.

  local getPosVelAtTime to getPosVelAtTimeFromOrbit().
  local getPositionError to {
      parameter simPos.
      return simPos:mag - landingPosition:mag.
  }.

  local function getPosVelAtTimeFromOrbit {
    return {
      parameter simTime.
      local fixRot to getBodyRotation(simTime).
      return list(fixRot * (positionat(ship, simTime) - body:position),
                  fixRot * (velocityat(ship, simTime):surface)).
    }.
  }

  local function getNodeError{
    parameter theNode, errorVec.

    local vecNodePrograde IS (velocityAt(ship,theNode:time):orbit):normalized.
    local vecNodeNormal IS (vCrs(vecNodePrograde,positionAt(ship,theNode:time) - body:position)):normalized.
    local progradeError IS vDot(errorVec,vecNodePrograde).
    local normalError IS vDot(errorVec,vecNodeNormal).

    return lex(
      "progradeError", progradeError,
      "normalError", normalError
    ).
  }

  local deltaCalcFallback to {
      parameter x1, y1.
      return min(max((-y1 * 0.001), -2), 2).
  }.
  local progradeMinimazer to newtonRapson(deltaCalcFallback@).
  local normalMinimazer to newtonRapson(deltaCalcFallback@).
  
  until false {
    set loopCount to loopCount + 1.

    local deorbitBurnData is simulateDeorbitBurn(deorbitData, settings[1], settings[2]).
    if simStartTime = 0 {
      set simStartTime to intersectTime - RocketUtils:getStageBurningTime(deorbitBurnData:surfaceVelocity:mag, engineIsp, shipThrust, deorbitBurnData:shipMass).
    }
    local landingData is calculateLandingBurn(simStartTime, shipThrust, engineIsp, deorbitBurnData:shipMass, settings[3], settings[4],
                                              getPosVelAtTime, getPositionError, landingProgressUpdater).
    
    set simStartTime to landingData:burnStartTime.

    local errorVec is landingData:landingPosition -   landingPosition.

    local nodeError is getNodeError(deorbitData:deorbitNode, errorVec).
    progressUpdater(lex("progradeError", nodeError:progradeError,
              "normalError", nodeError:normalError,
              "errorVector", errorVec:mag,
              "loopCount", loopCount,
              "deorbitThrust", deorbitBurnData:deorbitThrust,
              "settingsIndex", settingsIndex)).

    if abs(nodeError:progradeError) > settings[0] or abs(nodeError:normalError) > (settings[0] / 2) {
      local dx is progradeMinimazer:getDelta(deorbitData:deorbitNode:prograde, nodeError:progradeError).
      local dy is normalMinimazer:getDelta(deorbitData:deorbitNode:normal, nodeError:normalError).
      // if (abs(nodeError:progradeError) > 100 * settings[0] or  abs(nodeError:normalError) > settings[0] * 100) and settingsIndex > 0 {
      //   set settingsIndex to settingsIndex - 1.
      //   set settings to settingsList[settingsIndex].
      // }
      //drop values over limit.
      if abs(dx) < settings[4] and abs(dy) < settings[4] {
        set deorbitData:deorbitNode:prograde to deorbitData:deorbitNode:prograde + dx.
        if abs(nodeError:progradeError) < 5000 {
          set deorbitData:deorbitNode:normal to deorbitData:deorbitNode:normal + dy. 
        }
      }
      
    } else {
      set settingsIndex to settingsIndex + 1.
      if settingsIndex < settingsList:length {
        set settings to settingsList[settingsIndex].
      } else {
        return lex("landingData",landingData, "deorbitData", deorbitBurnData).
      }
    }
  }

  clearVecDraws().
}

local function calculateLandingBurn {
  parameter startTime, 
            shipThrust, 
            engineIsp, 
            shipMass, 
            deltaTimeList, 
            maxAltitudeError, 
            getPosVelAtTime, 
            getPositionError, 
            progressUpdaterF is { parameter simInfo. }.

  local posVelAtTime to list().
  local simBurnStartTime to timeLib:alignTimestamp(startTime).
  local simBurnStartDelay to 0.
  local simOldBurnStartDelay to 0.
  local simHistory to list().
  local simEndState to list().
  local errorMinimizer to newtonRapson({
      parameter x1, y1.
      return (y1/abs(y1)) * max(min(abs(y1)*0.01, 10), 0.02).
  }).
  
  // altitude correction
  local altitudeError to 0.
  local lastAltitudeError to 0.
  local simIsGoodEnough to false.

  local deltaTimeIndex to 0.

  until false {
      set posVelAtTime to getPosVelAtTime(simBurnStartTime).
      set simHistory to simulationLib:simulateToZeroVelocity(simBurnStartTime, posVelAtTime[0], posVelAtTime[1], shipMass, shipThrust, engineIsp, body, deltaTimeList[deltaTimeIndex]).
      set simEndState to simHistory[simHistory:length-1].
      set altitudeError to getPositionError(simEndState[1]).
      
      if abs(altitudeError) > maxAltitudeError {
          set simBurnStartDelay to timeLib:alignOffset(errorMinimizer:getDelta(simBurnStartTime, altitudeError)).
          set simBurnStartTime to simBurnStartTime + simBurnStartDelay.
      }
      else {
          set simBurnStartDelay to 0.
      }

      progressUpdaterF(lex("dt", deltaTimeList[deltaTimeIndex],
                          "steps", simHistory:length,
                          "velocityError", round(simEndState[2]:mag, 4),
                          "altitudeError", round(altitudeError, 2),
                          "burnStartDelay", simBurnStartDelay)).

      if (simBurnStartDelay = 0) or ((simBurnStartDelay + simOldBurnStartDelay) = 0) {
          set simIsGoodEnough to (simBurnStartDelay = 0) and (abs(altitudeError - lastAltitudeError) < 0.5).
          if (not simIsGoodEnough) and (deltaTimeIndex < (deltaTimeList:length - 1)) {
              set deltaTimeIndex to deltaTimeIndex + 1.
          }
          else {
              break.
          }
      }

      set lastAltitudeError to altitudeError.
      set simOldBurnStartDelay to simBurnStartDelay.
  }

  local burnStartTime to simBurnStartTime.
  local burnEndTime to timeLib:alignTimestamp(simEndState[0]).
  
  return lex(
      "burnStartTime", burnStartTime,
      "burnEndTime", burnEndTime,
      "landingPosition", simEndState[1]
  ).
}
local function simulateDeorbitBurn {
  parameter deorbitData,burnMinDt is 0.02, burnMaxDt is 0.06, engineIsp is RocketUtils:getAvarageISP().

  local burnVector is deorbitData:deorbitNode:burnVector.
  local deorbitBurningTime is RocketUtils:burnTimeForDv(burnVector:mag).
  local startTime is timeLib:alignTimestamp(deorbitData:deorbitNode:time - (deorbitBurningTime /2)).
  local endTime is startTime + timeLib:alignOffset(deorbitBurningTime)+1.
  local startPos is getBodyRotation(startTime) * positionAt(ship, startTime) -  body:position.
  local startVel is getBodyRotation(startTime) * velocityAt(ship, startTime):orbit.
  local deorbitThrust to RocketUtils:thrustFromBurnTime(burnVector:mag, engineIsp, deorbitBurningTime, ship:mass).
  local simulationHistory is simulationLib:simulateThrust(startTime, startPos,startVel, ship:mass, burnVector, endTime, deorbitThrust, engineIsp, body, burnMinDt, burnMaxDt).

  local burnEndState is simulationHistory[simulationHistory:length -1].
  
  local rotation is getBodyRotation(endTime, startTime).
  set burnEndState[1] to rotation * burnEndState[1].
  set burnEndState[1] to rotation * burnEndState[1].
  
  return lexicon(
    "shipMass", burnEndState[3],
    "surfaceVelocity", burnEndState[2] - vcrs(body:angularVel, burnEndState[1]),
    "startTime", startTime,
    "endTime", endTime,
    "burnTime", deorbitBurningTime,
    "deorbitThrust",deorbitThrust
  ).
}

local function calculateDeorbitNode {
  parameter deorbitNode, 
            settingsList,
            getDistanceError, 
            progessUpdater,
            minimum is body:radius * constant:pi,
            maxIteration is 5.
  
  local steps is 0.
  //stepsize, threshold, minstepsize, minThreshold, errorMargin
  local settingsIndex is 0.
  local settings is settingsList[settingsIndex].
  local stepSize is settings[0].
  local threshold is settings[1].
  local bestResult is lex().

  until false {
    local result is hillClimbLib:ddd_search(getDistanceError, deorbitNode:time, deorbitNode:normal, deorbitNode:prograde, 1/3, 1/10, minimum, stepSize ,threshold).

    if (minimum > result:minimum or steps > maxIteration){
      local compensation is max(0.8,min((result:minimum/minimum),0.95)).
      set stepSize to max(settings[2] , stepSize * compensation).
      set threshold to max(settings[3] , threshold * compensation).
      
      if steps <= maxIteration{
        set minimum to result:minimum.
        set bestResult to result.

      }
      
      set steps to 0.
    }

    progessUpdater(lex(
      "steps", steps,
      "minimum", minimum,
      "score", result:minimum,
      "stepSize", stepSize,
      "threshold", threshold,
      "settingsIndex", settingsIndex
    )).

    if minimum > settings[4] {
      set steps to steps + 1. 
    }else{
      set settingsIndex to settingsIndex + 1.
      if settingsIndex < settingsList:length {
        set settings to settingsList[settingsIndex].
        set stepSize to settings[0].
        set threshold to settings[1].
      }else {
        return bestResult.
      }
    }
    //Timeout 
    if (threshold < settingsList[settingsList:length-1][3]*1.2){
      return bestResult.
    }
  }
}

function getInitDeorbitDV {
  parameter universalTime, targetPE.

  local posAt is orbitalPositionVector(ship,universalTime).
  local sma is (targetPE+body:radius+posAt:mag)/2.
  local finalVel is sqrt(body:mu*(2/posAt:mag-1/sma)).

  return finalVel - velocityAt(ship, universalTime):orbit:mag.
}

local function progressUpdater {
    parameter simInfo.

    if simInfo:haskey("landingSimInfo") {
        local landingSimInfo to simInfo:landingSimInfo.
        print "============Landing Simulation========" at (60,20).
        print "|Sim done in " + landingSimInfo:steps + " steps with dt " + landingSimInfo:dt + "            " at (60,21).
        print "|AltErr: " + round(landingSimInfo:altitudeError, 2) + ", VelErr: " + round(landingSimInfo:velocityError,2) + "    " at (60,22).
        print "|BurnDelay:" +round(landingSimInfo:burnStartDelay, 3) + "      " at (60,23).
    }
    else {
        print "=============Landing error===========" at (60,24).
        print "|ProgradeErr: " + round(simInfo:progradeError, 2) + ", NormalErr: " + round(simInfo:normalError, 2) + "        " at (60,25).
        print "|errorVector: " + round(simInfo:errorVector, 2) + "        " at (60,26).
        print "|deorbitThrust:" + round(simInfo:deorbitThrust,2)+ "       " at (60,27).
        print "|LoopCount: " + simInfo:loopCount + "  " + "PrecisionIndex:" + simInfo:settingsIndex at (60,28).
    }
}.

local function newtonRapson {
    parameter initFunction.

    local initialized to false.
    local x0 to 0.
    local y0 to 0.

    local function getDelta {
        parameter x1, y1.
        
        local delta to 0.
        if initialized and x1 <> x0 and y1 <> y0 {
            // delta = -(y1 / yPrime)  ->  yPrime = (y1-y0)/(x1-x0)
            set delta to -(y1 / ((y1-y0)/(x1-x0))).
        }
        else {
            set initialized to true.
            set delta to initFunction(x1, y1).
        }

        set x0 to x1.
        set y0 to y1.

        return delta.
    }

    local function reset {
        set x0 to 0.
        set y0 to 0.
        set initialized to false.
    }

    return lex(
        "getDelta", getDelta@,
        "reset", reset@
    ).
}

local function refineOrbit {
  parameter trajectoryData.


  local velocityDataList is list().
  local positionDataList is list().
  for dataPoint in trajectoryData {
    velocityDataList:add(list(dataPoint[0], dataPoint[2])).
  }

  for dataPoint in trajectoryData {
    positionDataList:add(list(dataPoint[0], dataPoint[1])).
  }
  local interpolation to InterpolationLib:linearInterpolation(velocityDataList).
  local posInterpolation to InterpolationLib:linearInterpolation(positionDataList).
  local velocityError is v(100,0,0).
  local getVelocityError is {
    local velocityEstimation is interpolation:getValue(time:seconds).
    local positionEstimation is posInterpolation:getValue(time:seconds).
    set velocityError to velocityEstimation - velocityAt(ship, time):surface.

    local positionError is positionEstimation - (positionAt(ship,time) - body:position).
    
    print "|velocityError=" + velocityError:mag  at (60,30).
    print "|positionError=" + positionError:mag at (60,31).

    //vecDrawAdd(vecDrawLex,ship:position, 10000*velocityError,cyan,"velE").
    //vecDrawAdd(vecDrawLex,ship:position, positionError,purple,"posE").

    return velocityError.
  }.

  local stopCondition is {
    return (velocityError:mag < 0.0001) or interpolation:isNotFoundError() or (not rcs).
  }.
         
  print "==========Trajectory correction======" at (60,29).
  print "                                     " at (60,30).
  print "                                     " at (60,31).
  wait until abs(velocityDataList[0][0] - time:seconds) < 0.01.
  sas on.
  rcs on.
  NodeLib:cancelVelocityError(getVelocityError@, stopCondition@).
  rcs off.
}

local function cancelLandingError {
  parameter landingError, stopCondition.

  local pidVector is pidLib:pidVector(0.001, 0.002, 0.0002, -1, 1).

  pidVector:setpoint(v(0,0,0)).

  local shipControl is ship:control.
  sas on.
  rcs on.

  print "===========Landing correction========" at (60,29).
  print "                                     " at (60,30).
  print "                                     " at (60,31).

  until stopCondition() {
    //set shipControl:translation to v(0, 0, 0).
    local error is landingError():landingError.
    print "|landingError= " + error:mag at (60,30).
    set shipControl:translation to (-ship:facing) * pidVector:update(time:seconds, error).
    local burnDuration is min(error:mag/300, 1).
    print "|burnDuration= " + burnDuration at (60,31).
    //wait burnDuration.
    vecDrawAdd(vecDrawLex,ship:position, error ,purple,"landingError").
  }

  set shipControl:translation to v(0, 0, 0).
}