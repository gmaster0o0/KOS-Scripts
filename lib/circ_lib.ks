
function waitToApoapsis {
  parameter lead is 10.

  lock  throttle to 0.
  printO("CIRC","Varunk aming az apoapsishoz erunk").
  until eta:apoapsis < lead {
    cancelWarpBeforeEta(eta:apoapsis,lead).
  }
}

function waitToPeriapsis {
  parameter lead is 10.

  lock  throttle to 0.
  printO("CIRC","Varunk aming az periapsishoz erunk").
  until eta:periapsis < lead {
    cancelWarpBeforeEta(eta:periapsis,lead).
  }
}

function raisePeriapsis {
  parameter targetPeri is apoapsis.
  parameter errorTreshold is 1.05.

  local dv is deltaVToPeriapsis().
  local bt is burnTimeForDv(dv).
  waitToApoapsis(bt/2).

  printO("CIRC","Periapsis emelese:[DV:"+round(dv,1)+"][BT:"+round(bt,1)+"]").
  lock throttle to 1.
  lock steering to circPrograde().
  until status = "ORBITING" and (
    orbit:eccentricity < 0.0005 or 
    periapsis > targetPeri*errorTreshold or
    apoapsis > targetPeri * errorTreshold
  ) {
    local perc is periapsis/targetPeri. 
    flightData().
    checkBoosters().
    if(perc>0.9){
      lock throttle to max(0.05,1-perc).
    }
  }
  printO("CIRC","Körpálya elérve:"+ orbit:eccentricity).
  lock throttle to 0.
}

function lowerApoapsis {
  parameter targetApo is periapsis.
  parameter errorTreshold is 0.95.

  local dv to deltaVToPeriapsis().
  local bt to burnTimeForDv(dv).
  
  lock steering to circRetrograde().
  wait until steeringManager:ANGLEERROR < 1.
  waitToPeriapsis(bt/2).

  printO("CIRC", "Gyorsítás a körpálya eléréséhez. DV:" + round(dv,1) + "  BT:"+round(bt)).
  local th to 1.
  lock throttle to th.
  until status="ORBITING" and (
    periapsis < targetApo*errorTreshold or 
    apoapsis < targetApo*errorTreshold or 
    orbit:eccentricity < 0.0005
  ) {
    set th to burnTimeForDv(deltaVToPeriapsis()).
    checkBoosters().
  }
  printO("CIRC", "Körpálya elérve:" + round(obt:eccentricity,7)).
  lock throttle to 0.
}

function circPrograde {
  parameter threshold is 30.

  if(eta:apoapsis < eta:periapsis){
    //print "-30..0" + r(0,max(-eta:apoapsis,-threshold),0) at (0,30).
    return prograde:vector + r(0,max(-eta:apoapsis,-threshold),0).
  }
  //print "0..30" + r(0,min(orbit:period - eta:apoapsis,threshold),0) at (0,31).
  return prograde:vector + r(0,min(orbit:period - eta:apoapsis,threshold),0).
}

function circRetrograde {
  parameter threshold is 30.

  if orbit:eccentricity > 1 {
    if eta:periapsis > 0 {
      //print "-30..0 + r(0,max(-eta:periapsis,-30),0).
      return retrograde:vector + r(0,max(-eta:periapsis,-threshold),0).
    }
    //print "0..30" + r(0,min(-eta:periapsis,30),0).
    return retrograde:vector + r(0,min(-eta:periapsis,threshold),0).
  }
  if eta:periapsis < eta:apoapsis {
    return retrograde:vector + r(0,max(-eta:periapsis,-threshold),0).
  }
  return retrograde:vector + r(0,min(orbit:period - eta:periapsis,threshold),0).
}

