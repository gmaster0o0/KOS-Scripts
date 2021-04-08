
function waitToApoapsis {
  parameter lead is 10.

  lock  throttle to 0.
  printO("CIRC","Varunk aming az apoapsishoz erunk").
  until eta:apoapsis < lead {
    flightData().
  }
}

function raisePeriapsis {
  parameter targetPeri is apoapsis.
  parameter errorTreshold is 1.05.

  local dv is deltaVToPeriapsis().
  local bt is burnTimeForDv(dv).
  waitToApoapsis(bt/2).

  printO("CIRC","Periapsis emelese:[DV:"+dv+"][BT:"+bt+"]").
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

function circPrograde {
  parameter threshold is 30.

  if(eta:apoapsis < eta:periapsis){
    //print "-30..0" + r(0,max(-eta:apoapsis,-threshold),0) at (0,30).
    return prograde:vector + r(0,max(-eta:apoapsis,-threshold),0).
  }
  //print "0..30" + r(0,min(orbit:period - eta:apoapsis,threshold),0) at (0,31).
  return prograde:vector + r(0,min(orbit:period - eta:apoapsis,threshold),0).
}