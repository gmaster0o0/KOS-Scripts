function waitForTransferWindow {
  local tAngVel is 360/target:obt:period.
  local sAngVel is 360/ship:obt:period.
  local angleChangeRate is abs(tAngVel-sAngVel).
  local dv to hohhmanDv().
  local bt to burnTimeForDv(dv).
  local ht to hohmanmTime().

  local ETAofTransfer to abs(getTargetAngle() - hohmanmTime())/ angleChangeRate.
  printO("TRANSFER","Hohhman pályamódosítás. DV:" + round(dv,1) + "  BT:"+round(bt)).
  printO("TRANSFER","Hohhman time:" + round(ht,1)).

  until ETAofTransfer - bt/2 {
    wait 1.
    set tAngVel to 360/target:obt:period.
    set sAngVel to 360/ship:obt:period.
    local targetAng to getTargetAngle().
    set angleChangeRate to abs(tAngVel-sAngVel).
    set ETAofTransfer to abs(getTargetAngle() - hohmanmTime())/ angleChangeRate.

    print round(targetAng) at (15,1).
    print round(ETAofTransfer) at (15,2).
    print round(angleChangeRate) at (15,3).
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

function lngToDegrees {
  parameter lng.

  return mod(lng + 360, 360).
}

function getTargetAngle {
  return lngToDegrees(lngToDegrees(target:longitude) - lngToDegrees(ship:longitude)).
}
