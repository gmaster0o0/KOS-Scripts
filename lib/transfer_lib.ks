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
  lock steering to prograde.
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

function escapeTransfer {
  parameter PE_GOAL is 30000.
  parameter targetBody is body("KERBIN").

  local RET_AP to body:altitude + body:radius.
  print "RET_AP:     " + RET_AP.
  local RET_PE to PE_GOAL + targetBody:radius.
  print "RET_PE:     " + RET_PE.
  local RET_SMA to (RET_PE+RET_AP)/2.
  print "RET_SMA:     " + RET_SMA.
  local V_AP to sqrt(targetBody:mu * (2/(RET_AP) - (1/RET_SMA))).
  print "V_AP:     " + V_AP.
  local V_OBT to body:OBT:VELOCITY:ORBIT:MAG.
  print "V_OBT:     " + V_OBT.
  local V_REL to V_OBT - V_AP.
  print "V_REL:     " + V_REL.  
  local R_PE is  periapsis +body:radius.
  print "R_PE:     " + R_PE.
  local R_AP is  apoapsis +body:radius.
  print "R_AP:     " + R_AP.

  local V_ESC0 to sqrt(body:mu * (2/(R_PE)-1/(body:SOIRADIUS + R_PE)/2)).
  print "V_ESC0:     " + V_ESC0.
  
  local V_ESC1 to sqrt(2*body:mu / R_PE).
  print "V_ESC1:     " + V_ESC1.

  local V_ESC2 to sqrt(body:mu * (2/R_PE + 1/(R_PE+ body:soiradius))).
  print "V_ESC2:     " + V_ESC2.

  local V_ESC is V_ESC0.
  //V_REL = V_EXC. V_EXC^2 = V_BO^2 - V_ESC^2 
  local V_BO to sqrt(V_REL^2 + V_ESC^2).
  print "V_BO:     " + V_BO.
    
  local V_CURRENT to VELOCITY:ORBIT:MAG.
  print "V_CURRENT:     " + V_CURRENT.
  local DeltaV to V_BO - V_CURRENT.
  print "DeltaV:      " + DeltaV.
  local BurnTime to burnTimeForDv(DeltaV).
  print "Burn Time:      " + BurnTime.
  local SMA_HYP is 1/(2/R_PE-(V_BO^2/body:mu)).
  print "SMA_HYP:     " + SMA_HYP.
  local HYP_ECC is 1 - R_PE/SMA_HYP.
  print "HYP_ECC:     " + HYP_ECC.
  //angle betwee dep asymptote and periapsis vector
  local A_ANGLE is ARCCOS(-1/HYP_ECC).
  print "A_ANGLE:       " +  A_ANGLE.
  local BODY_VEL_V is BODY:OBT:VELOCITY:ORBIT.
  local SHIP_V_V is SHIP:VELOCITY:ORBIT.
  local SHIP_P_V to body:position.
  local SHIP_N_V to vCrs(SHIP_P_V,SHIP_V_V):normalized.
  LOCAL ORBIT_ANGLE to lngToDegrees(arcTan2(vDot(vCrs(SHIP_V_V,BODY_VEL_V),SHIP_N_V),vDot(SHIP_V_V,BODY_VEL_V))).
  print "OBT_ANGLE:     " + ORBIT_ANGLE.
  local SHIP_ANG_VEL is 360/ship:orbit:period.
  print "SHIP_ANG_VEL:     " + SHIP_ANG_VEL.
  print "ANG_DIFF:      " + utilReduceTo360(A_ANGLE - ORBIT_ANGLE).
  local PHASE_ETA is utilReduceTo360(A_ANGLE - ORBIT_ANGLE) / SHIP_ANG_VEL.
  print "PHASE_ETA:     " + PHASE_ETA.
  print "================================================".

  lock steering to prograde.

  local n to node(time:seconds + PHASE_ETA, 0, 0, DeltaV).
  add n.

  until (PHASE_ETA < burnTime/2) {
    set BODY_VEL_V to body:OBT:VELOCITY:ORBIT.
    set SHIP_V_V to SHIP:VELOCITY:ORBIT.
    set SHIP_P_V to body:position.
    set SHIP_N_V to vCrs(SHIP_P_V,SHIP_V_V):normalized.

    //CLEARVECDRAWS().
    //drawVec(BODY_VEL_V,RED,"BODY_VEL_V").
    //drawVec(SHIP_V_V,BLUE,"SHIP_V_V").
    //drawVec(SHIP_N_V,WHITE,"SHIP_N_V").

    set ORBIT_ANGLE to lngToDegrees(arcTan2(vDot(vCrs(SHIP_V_V,BODY_VEL_V),SHIP_N_V),vDot(SHIP_V_V,BODY_VEL_V))).
    print "OBT_ANGLE:  " + ORBIT_ANGLE + "     " at (5,33).
    print "A_ANGLE:  " + A_ANGLE + "     "at (5,34).
    print "ANG_DIFF: " + utilReduceTo360(A_ANGLE - ORBIT_ANGLE) + "     "at (5,35).
    set PHASE_ETA to utilReduceTo360(A_ANGLE - ORBIT_ANGLE) / SHIP_ANG_VEL.
    print "PHASE_ETA:  " + Round(PHASE_ETA) + "     " at (5,36).
    wait 1.
    if PHASE_ETA < burnTime+60{
      KUNIVERSE:TIMEWARP:CANCELWARP().
      WAIT UNTIL SHIP:UNPACKED.
    }

  }
  wait until steeringManager:ANGLEERROR < 1.
  printO("TRANSFER","Pályamódosítás megkezdése").
  local th to 1.
  lock throttle to th.
  local DONE is false.
  until V_BO - SHIP:VELOCITY:ORBIT:mag < 0.2 or DONE {
    set BODY_VEL_V to body:OBT:VELOCITY:ORBIT.
    set SHIP_V_V to SHIP:VELOCITY:ORBIT.

    // CLEARVECDRAWS().
    // drawVec(BODY_VEL_V,RED,"BODY_VEL_V").
    // drawVec(SHIP_V_V,BLUE,"SHIP_V_V").
    local DVLeft is V_BO-SHIP:VELOCITY:ORBIT:mag.
    set th to DVLeft / (ship:availableThrust/ship:mass).
    print "DVLeft: " + Round(DVLeft,2) + "                      "at (5,37).
    if obt:hasNextPatch {
      set DONE to obt:nextPatch:periapsis < PE_GOAL.
    }
  }
  set th to 0.
  printO("TRANSFER","Pályamódosítás befejezve").
}

function doOrbitTransfer {
  lock steering to prograde.
  wait until steeringManager:ANGLEERROR < 1.
  local th is 1.
  lock throttle to th.
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

function utilReduceTo360 {
	parameter ang.
	return ang - 360 * floor(ang / 360).
}

