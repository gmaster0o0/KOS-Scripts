function raisePeriapsis {
  parameter targetPeri is apoapsis.
  parameter errorTreshold is 1.05.

  local dv is deltaVToPeriapsis().
  local bt is burnTimeForDv(dv).
  waitToApoapsis(bt/2).

  printO("CIRC","Periapsis emelese:[DV:"+round(dv,1)+"][BT:"+round(bt,1)+"][AP:"+targetPeri+"]").
  lock throttle to 1.
  lock steering to circPrograde().
  until status = "ORBITING" and (
    (orbit:eccentricity < 0.0005 and isCloseTo(targetPeri,periapsis,targetPeri*0.01)) or
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
  print targetApo.
  local dv to deltaVToPeriapsis().
  local bt to burnTimeForDv(dv).
  
  lock steering to circRetrograde().
  wait until steeringManager:ANGLEERROR < 1.
  waitToPeriapsis(bt/2).

  printO("CIRC", "Gyorsítás a körpálya eléréséhez. DV:" + round(dv,1) + "  BT:"+round(bt)).
  local th to 1.
  lock throttle to th.
  local startPeri is periapsis.
  until status="ORBITING" and (
    periapsis < startPeri*errorTreshold or 
    (apoapsis < targetApo*errorTreshold and apoapsis > 0) or 
    orbit:eccentricity < 0.0005
  ) {
    print apoapsis at (10,10).
    print targetApo*errorTreshold  at (10,11).
    print periapsis < startPeri*errorTreshold  at (10,12).
    print apoapsis < targetApo*errorTreshold and apoapsis > 0  at (10,13).
    print orbit:eccentricity < 0.0005  at (10,14).
    set th to burnTimeForDv(deltaVToPeriapsis()).
    checkBoosters().
    wait 0.1.
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