runPath("../lib/staging_lib.ks").

clearScreen.
parameter targetApo is 80000.

local mypart is "KERBINTOURS".

function printO {
  parameter part.
  parameter msg.

  print "T+" + round(time:seconds) + "["+ part + "]" + msg.
}

function flightData {
  print apoapsis at (15,1).
  print periapsis at (15,2).
  print altitude at (15,3).
}

print "========KERBINTOURS========".
print "APOAPSIS:".
print "PERIAPSIS:".
print "ALTITUDE:".


printO(mypart,"KILOVES").
lock pitch  to max(8,90*(1-apoapsis/body:atm:height)).
lock steering to heading(90,pitch).
lock throttle to 1.
stage.

printO(mypart,"EMELKEDES").
until apoapsis > targetApo {
  flightData().
  checkBoosters().
}

lock throttle to 0.
printO(mypart,"Varakozas amig kierunk az atmoszferabol").
until altitude > body:atm:height {
  flightData().
}

printO(mypart,"Varunk aming az apoapsishoz erunk").
until eta:apoapsis < 10 {
  flightData().
}

printO(mypart,"Periapsis emelese").
lock  throttle to 1.
lock steering to prograde.
until periapsis > 70000 {
  flightData().
  checkBoosters().
  if (eta:apoapsis < eta:periapsis and eta:apoapsis > 10) or 
     (eta:apoapsis - ship:orbit:period > - 10 and eta:apoapsis > eta:periapsis) 
  {
    lock  throttle to 0.
  } else {
    lock  throttle to 1.
  }
}

lock  throttle to 0.
wait 20.

printO(mypart,"Varunk aming az apoapsishoz erunk").
until eta:apoapsis < 10 {
  flightData().
}

printO(mypart,"Periapsis csokkentese").
lock  throttle to 1.
lock steering to retrograde.
until  periapsis < 20000 {
  flightData().
  checkBoosters().
}
lock  throttle to 0.

printO(mypart,"Varunk aming az atmoszferaba erunk").
until altitude < body:atm:height {
  flightData().
}

printO(mypart,"Ejtoernyo program aktivalasa").
doSafeParachute().

printO(mypart,"TOUCHDOWN").