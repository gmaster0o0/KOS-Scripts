function changePeriod {
  local targetPeriod is target:obt:period.
  local newPeriod is targetPeriod + targetPeriod * (360-getTargetAngle())/360.

  local dv is hohhmanDVFromPeriod(newPeriod).
  local bt is burnTimeForDv(dv).

  local correction is 1.
  if newPeriod > ship:orbit:period {
    lock steering to prograde.
  }else {
    lock steering to retrograde.
    set correction to -1.
  }
  
  waitToPeriapsis(bt/2).

  printO("REND", "Pálya modósítás." + ship:obt:period).
  printO("REND", "Pálya modósítás. DV:" + dv + " BT:"+ bt).
 
  lock throttle to 1.
  //1: NEW:15 > current:10 C=>16  C:16 > N:15 OK
  //-1 NEW:5 > current:4 C=>4   C:4>N:5 NEM OK..... C:-4 >N:-5
  until correction * ship:orbit:period > newPeriod * correction {
  }
  printO("REND", "Pálya módosítva. Új keringési idő:" + newPeriod).
  lock throttle to 0.

  waitToPeriapsis().
}

function waitTheClosestDistance {
  local done is false.

  //diff > 0 novekszik
  //diff < 0 csokken
  local diff is 0.

  until done {
    local prev is target:distance.
    wait 1.

    if diff < 0 and prev < target:distance {
      set done to true.
    }
    set diff to prev - target:distance.

    //velocityVectorsDraw().
  }
  printO("REND", "Legkisebb tavolsag elerve:" + target:distance).
  CLEARVECDRAWS().
}

function killRelVel {
  parameter velGoal is 1.

  local relVelVec to target:velocity:orbit - ship:velocity:orbit.
  lock steering to relVelVec.
  local maxSpeed is relVelVec:mag.
  local prevSpeed is relVelVec:mag.

  wait until steeringManager:ANGLEERROR < 1.
  local th is 1.
  printO("REND", "Relativ sebesseg eliminalasa:"+ maxSpeed).
  until relVelVec:mag < velGoal or prevSpeed - relVelVec:mag < -1 {
    wait 0.1.

    set prevSpeed to relVelVec:mag.
    set relVelVec to target:velocity:orbit - ship:velocity:orbit.
    set th to relVelVec:mag / (ship:availableThrust/ship:mass).
    lock throttle to th.

    //velocityVectorsDraw().
  }
  lock throttle to 0.
  printO("REND", "Relativ sebesseg eliminalva. Hiba:" + relVelVec:mag).
  CLEARVECDRAWS().

  return maxSpeed.
}

function decreaseDistance {
  parameter distanceGoal is 50.
  parameter maxSpeed is 300.

  local turningTime is 5.

  printO("REND", "Tavolsag csokkentese:" + target:distance + " maxSpeed:"+ maxSpeed).
  lock steering to target:position.
  wait turningTime.

  local relVelVec to target:velocity:orbit - ship:velocity:orbit.
  local startDistance is target:distance.
  local engineAcc is ship:availablethrust /ship:mass.

  local th is getThrottle(turningTime,startDistance,relVelVec:mag).
  lock throttle to th.

  until target:distance < startDistance/2 or 
        target:distance < distanceGoal or
        shipCannotStop(engineAcc, turningTime) or
        relVelVec:mag > maxSpeed
  {
    set relVelVec to target:velocity:orbit - ship:velocity:orbit.
    set th to getThrottle(turningTime, startDistance,relVelVec:mag).
    //positionVectorsDraw().
  }

  lock throttle to 0.
  CLEARVECDRAWS().
  printO("REND", "Új távolság:" + target:distance).
  lock steering to relVelVec.
  wait turningTime.
}

function shipCannotStop {
  parameter engineAcc.
  parameter turningTime.

  local relVelVec to target:velocity:orbit - ship:velocity:orbit.
  local v1 is relVelVec:mag.
  local rotateDistance is v1* turningTime.
  local breakingDistance is v1^2 / (2*engineAcc).
  local stoppingDistance is rotateDistance + breakingDistance.

  return stoppingDistance > target:distance.
}

function getThrottle {
  parameter maxBurningTime is 4.
  parameter d0 is 50.
  parameter v0 is 0.

  //d = vi*t + (a*t^2)/2 ==>
  //a = 2*(d - vi*t) / t^2
  local maxAcc is 2 * (d0 + v0*maxBurningTime) / maxBurningTime^2.
  local enginesAcc is ship:availablethrust/ ship:mass.

  return maxAcc / enginesAcc.
}

function approcheTarget {
  parameter distanceGoal is 50.

  waitTheClosestDistance().
  until target:distance < distanceGoal {
    local lastVel to killRelVel().
    decreaseDistance(distanceGoal, lastVel).
    if target:distance > 4000 {
      waitTheClosestDistance().
    }
  }
  printO("REND", "Cel tavolsag elerve. Hiba" + abs(distanceGoal - target:distance)).
}

function finishRendezvous {
  lock steering to target:direction.
  wait 3.
  unlock all.
  sas on.
}

function velocityVectorsDraw {
  parameter vectorSize is 0.5.

  CLEARVECDRAWS().
  local shipVV TO VECDRAW(
    V(0,0,0),
    ship:velocity:orbit,
    RED,
    "SV",
    vectorSize,
    TRUE,
    0.2,
    TRUE,
    TRUE
  ).
  local shipTV TO VECDRAW(
    V(0,0,0),
    target:velocity:orbit,
    GREEN,
    "TV",
    vectorSize,
    TRUE,
    0.2,
    TRUE,
    TRUE
  ).
  local shipSubV TO VECDRAW(
    V(0,0,0),
    target:velocity:orbit - ship:velocity:orbit,
    BLUE,
    "BURN",
    vectorSize,
    TRUE,
    0.2,
    TRUE,
    TRUE
  ).
}

function positionVectorsDraw {
  parameter vectorSize is 0.5.

    CLEARVECDRAWS().
    local shipVV TO VECDRAW(
    V(0,0,0),
    ship:velocity:orbit,
    RED,
    "SV",
    vectorSize,
    TRUE,
    0.2,
    TRUE,
    TRUE
  ).
  local shipTV TO VECDRAW(
    V(0,0,0),
    target:position,
    GREEN,
    "TV",
    vectorSize,
    TRUE,
    0.2,
    TRUE,
    TRUE
  ).
  local shipSubV TO VECDRAW(
    V(0,0,0),
    target:position,
    BLUE,
    "Burn",
    vectorSize,
    TRUE,
    0.2,
    TRUE,
    TRUE
  ).
}
