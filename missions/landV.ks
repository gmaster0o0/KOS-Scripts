runPath("../lib/landing_lib.ks").
runPath("../lib/ui_lib.ks").
runPath("../lib/rocket_utils_lib.ks").
runPath("../lib/staging_lib.ks").
runPath("../lib/utils_lib.ks").
runPath("../lib/wait_lib.ks").
runPath("../lib/warp_lib.ks").

parameter verbose is true.

function waitForStart {
  clearVecDraws().
  clearScreen.
  print "PRESS ABORT TO START LANDING!" at (30,10).
  wait until abort.
  set abort to false.
  sas off.
  lock steering to retrograde.
  clearScreen.
  createDisplay().
  wait 5.
}

function createDisplay {
  if verbose {
    print "STATUS" at (40,0).
    print "verticalspeed" at (40,1).
    print "altRadar" at (40,2).
    print "maxAccUp" at (40,3).
    print "gravity" at (40,4).
    print "ffSpeed" at (40,5).
    print "impactTime" at (40,6).
    print "burningTime" at (40,7).
    print "breakingDistance" at (40,8).
    print "throttle" at (40,9).
    print "P_INP" at (40,10).
    print "StopTime" at (40,11).
    print "SurfaceSpeed" at (40,12).
  }
}

function killhorizontalspeed {
  print "KILL HORIZONTAL SPEED" at (60,0).
  local th is 0.
  lock throttle to th.

  lock groundVelVec to vxcl(up:vector, ship:velocity:surface).
  lock steering to verticalSpeed * up:vector - ship:velocity:surface.
  wait until steeringManager:ANGLEERROR < 1.

  until groundVelVec:mag < 3 {
    set th to groundVelVec:mag / 10.
    fdata().
  }
}

function fdata {
    parameter stopDistance is "".

    local groundVelVec is vxcl(up:vector, ship:velocity:surface).

    if verbose {
    print verticalSpeed at (60,1).
    print ship:bounds:bottomaltradar at (60,2).
    print stopDistance at (60,8).
    print throttle at (60,9).
    print groundVelVec:mag at (60,12).
  }
}

function suicideBurn {
  parameter hoverSpeed is -1.

  local th is 0.
  lock throttle to th.
  
  local minAlt is 1.

  local suicidePID to pidLoop(0.5,0.05,0.05,0,1).
  set suicidePID:setpoint to minAlt.

  rcs on.
  panels off.
  gear on.

  local done is false.
  lock steering to srfRetrograde.

  until done {
    print "SUICIDE BURN" at (60,0).
    local groundDistance to ship:bounds:bottomaltradar-minALT.

    set th to suicidePID:update(time:seconds,groundDistance - calculateStoppingDistance()).
    print suicidePID:input at (60,10).
    set done to abs(verticalSpeed) < 5 and groundDistance < minAlt.
  }

  suicidePID:reset().
  set suicidePID:setpoint to hoverSpeed.
  lock steering to up:vector*alt:radar - ship:velocity:surface.

  until status = "LANDED" {
    print "FINAL TOUCH" at (60,0).
    print suicidePID:input at (60,10).
    set th to suicidePID:update(time:seconds,verticalSpeed).
  }
  set th to 0.
  print "LANDED" at (60,0).
  wait 1.
  unlock all.
  sas on.
  wait 3.
  panels on.
  rcs off.
}

function gravity {
  parameter h is altitude.
  return body:mu / ( body:radius+ h) ^2.
}

function avgGrav {
  parameter startAlt is altitude.
  parameter dist is altitude.

  return (gravity(startAlt) + gravity(startAlt-dist))/2.
}

function maxAccUp {
  parameter h is altitude.
  // F = m*a
  local shipMaxAcceleration is ship:availablethrust / ship:mass.
  return shipMaxAcceleration - avgGrav(h,h).
}

function calculateStoppingDistance {
  //t= v/a
  // d = 1/2 * a * t*t
  local stopTime is abs(verticalSpeed) / maxAccUp().
  print stopTime at (60,11).
  local stopDistance is 1/2 * maxAccUp() * stopTime^2.
  fdata(stopDistance).

  return stopDistance.
}
//STARTING HERE
waitForStart().
deOrbitBurn(0).
killhorizontalspeed().
suicideburn().

//+final touch