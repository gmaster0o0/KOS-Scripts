function waitForTransferWindow {
  local tAngVel is 360/target:obt:period.
  local sAngVel is 360/ship:obt:period.
  local angleChangeRate is abs(tAngVel-sAngVel).
  local dv to hohmannDv().
  local bt to burnTimeForDv(dv).
  local ht to hohmanmTime().

  local ETAofTransfer to (getTargetAngle() - hohmanmTime()) / angleChangeRate.
  printO("TRANSFER","Hohhman pályamódosítás. DV:" + round(dv,1) + "  BT:"+round(bt)).
  printO("TRANSFER","Hohhman time:" + round(ht,1)).

  until ETAofTransfer < bt/2 {
    wait 1.
    set tAngVel to 360/target:obt:period.
    set sAngVel to 360/ship:obt:period.
    local targetAng to getTargetAngle().
    set angleChangeRate to abs(tAngVel-sAngVel).
    set ETAofTransfer to (getTargetAngle() - hohmanmTime()) / angleChangeRate.
    print round(targetAng,1) at (25,1).
    print round(ETAofTransfer,1) at (25,2).
    print round(angleChangeRate,2) at (25,3).
  }
}

function doOrbitTransfer {
  local th is 1.
  lock throttle to th.
  lock steering to prograde.
  printO("TRANSFER","Pályamódosítás megkezdése").
  until apoapsis > target:apoapsis {
    if(apoapsis /target:apoapsis > 0.9){
      set th to max(0.05,1-(apoapsis/target:apoapsis)).
    }else {
      set th to 1.
    }
    checkBoosters().
  }
  printO("TRANSFER","Pályamódosítás befejezve:"+ round(apoapsis)).
  unlock all.
}

function waitToEncounter {
  wait until status = "ESCAPE".
  printO("TRANSFER",target:name + "Vonzáskörzete elérve").
}

function waitUntilLeaveSOI {
  parameter home is "KERBIN".
  local OldSOI is body:name.
  wait until body:name = home.
  printO("TRANSFER",OldSOI + "Vonzáskörzete elhagyva").
}

function avoidCollision {
  printO("TRANSFER", "Elkerülő manőver.PE:" + periapsis).
  parameter minPer is 40000.
  if periapsis < 40000 {
    lock steering to heading (90,0).
    wait 10.
    lock throttle to 1.
    until periapsis > minPer {
      if periapsis / minPer > 0.9 {
        lock throttle to max(0.05, 1-periapsis / minPer ).
        print "PE:" at (0,1).
        print periapsis at (15,1).
      }
    }
    lock throttle to 0.

    printO("TRANSFER", "Elkerülő manőver befejezve.PE:" + periapsis).
  }
  wait 2.
}


function lngToDegrees {
  parameter lng.

  return mod(lng + 360, 360).
}

function getTargetAngle {
  return lngToDegrees(lngToDegrees(target:longitude) - lngToDegrees(ship:longitude)).
}
