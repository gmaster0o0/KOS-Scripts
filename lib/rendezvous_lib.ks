local hohhmanLib is HohhmanLib().

function changePeriod {
  local targetPeriod is target:obt:period.
  local newPeriod is targetPeriod + targetPeriod * (360-getTargetAngle())/360.

  local newSemiMajorAxis is ((body:mu * newPeriod^2)/(4 * constant:pi))^(1/3).
  local newSemiMinorAxis is newSemiMajorAxis * sqrt(1-obt:eccentricity).
  local dv is hohhmanLib:transferDeltaV((ship:orbit:semimajoraxis+ship:orbit:semiminoraxis)/2, (newSemiMajorAxis+newSemiMinorAxis)/2).
  
  local bt is burnTimeForDv(dv).
  local correction is 1.
  if newPeriod > ship:obt:period {
    lock steering to prograde.
  }else {
    lock steering to retrograde.
    set correction to -1.
  }
  waitToPeriapsis(bt/2).
  lock throttle to 1.
  //1: New:15 > current : 10 => C=>16 N= 15, 16>15 OK
  //-1: New 10 < current:15 => C=>9 N=10,  9>10 NEMOK.... -9 > -10
  until ship:obt:period * correction > correction * newPeriod {
  }
  printO("REND", "Orbit modified. New period time:" + newPeriod).
  lock throttle to 0.

  waitToPeriapsis().
}

function  approcheTarget {
  parameter distanceGoal is 50.
  parameter turningTime is 10.
  parameter fast is true.
  
  waitTheClosestDistance().
  until target:distance < distanceGoal {
    local lastVel to killRelVel().
    decreaseDistance(distanceGoal, lastVel,turningTime).
    if target:distance > 2000 or not fast{
      waitTheClosestDistance().
    }
  }
  printO("REND", "Target distance reached. Error:" + abs(distanceGoal - target:distance)).
}

function killRelVel {
  parameter velGoal is 1.

  local relVelVec to target:velocity:orbit - ship:velocity:orbit.
  lock steering to relVelVec.
  local maxSpeed is relVelVec:mag.
  local prevSpeed is relVelVec:mag.
  wait until abs(steeringManager:ANGLEERROR < 1).
  local th is 1.

  printO("REND", "Eliminate relative velocity:"+ maxSpeed).
  until relVelVec:mag < velGoal or prevSpeed - relVelVec:mag < -1 {
    wait 0.1.
    set prevSpeed to relVelVec:mag.
    set relVelVec to target:velocity:orbit - ship:velocity:orbit.
    set th to relVelVec:mag / (ship:availableThrust/ship:mass).
    lock throttle to th.
  }

  lock throttle to 0.
  printO("REND", "Relative velocity eliminated. Error:" + relVelVec:mag).

  return maxSpeed.
}

function finishRendezvous {
  lock steering to target:direction.
  wait 3.
  unlock all.
  sas on.
}

local function waitTheClosestDistance {
  local done is false.

  //diff > 0 novekszik
  //diff < 0 csokken
  local diff is 0.
  lock steering to -target:position.
  until done {
    local prev is target:distance.
    wait 1.

    if diff < 0 and prev < target:distance {
      set done to true.
    }
    set diff to prev - target:distance.

  }
  printO("REND", "Legkisebb tavolsag elerve:" + target:distance).
  CLEARVECDRAWS().
}

local function decreaseDistance {
  parameter distanceGoal is 50.
  parameter maxSpeed is 300.
  parameter turningTime is 10.

  printO("REND", "Tavolsag csokkentese:" + target:distance + " maxSpeed:"+ maxSpeed).
  lock steering to target:position.
  wait turningTime.
  
  local relVelVec to target:velocity:orbit - ship:velocity:orbit.
  local startDistance is target:distance.
  local engineAcc is ship:availablethrust / ship:mass.

  local th is getThrottle(turningTime,startDistance,relVelVec:mag).

  lock throttle to th.
  until target:distance < startDistance/2 or 
        target:distance < distanceGoal or
        shipCannotStop(engineAcc, turningTime) or
        relVelVec:mag > maxSpeed*0.5
  {
    set relVelVec to target:velocity:orbit - ship:velocity:orbit.
    set th to getThrottle(turningTime, startDistance,relVelVec:mag).
  }
  lock throttle to 0.
  printO("REND", "Új távolság:" + target:distance).
  lock steering to relVelVec.
  wait turningTime.
}

local function shipCannotStop {
  parameter engineAcc.
  parameter turningTime.

  local relVelVec to target:velocity:orbit - ship:velocity:orbit.
  local v1 is relVelVec:mag.
  local rotateDistance is v1* turningTime*2.
  local breakingDistance is v1^2 / (2*engineAcc).
  local stoppingDistance is rotateDistance + breakingDistance.

  return stoppingDistance > target:distance.
}

local function getThrottle {
  parameter maxBurningTime is 4.
  parameter d0 is 50.
  parameter v0 is 0.

  local maxAcc is 2 * (d0 + v0*maxBurningTime) / maxBurningTime^2.
  local enginesAcc is ship:availablethrust/ ship:mass.

  return maxAcc / enginesAcc.
}
