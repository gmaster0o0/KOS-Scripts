//TODO refactor this.

function TransferLib {
  parameter vecDebug is false.
  parameter verbose is false.
  
  local vecDrawLex is lex().
  
  local function transferTo {
  }

  return lexicon(
    "transferTo",transferTo@
  ).
}
//LEGACY
local verbose is false.
local hohhmanLib is HohhmanLib().

function waitForTransferWindow {
  clearscreen.
  local tAngVel is 360/target:obt:period.
  local sAngVel is 360/ship:obt:period.
  local angleChangeRate is abs(tAngVel-sAngVel).
  local dv to hohhmanLib:transferDeltaV().
  local bt to burnTimeForDv(dv).
  local ht to hohhmanLib:hohmanmTime().

  local ETAofTransfer to utilReduceTo360(getTargetAngle() - hohhmanLib:hohmanmTime()) / angleChangeRate.
  printO("TRANSFER","Hohhman pályamódosítás. DV:" + round(dv,1) + "  BT:"+round(bt)).
  printO("TRANSFER","Hohhman time:" + round(ht,1)).
  printO("TRANSFER","ETA" + round(ETAofTransfer,1)).
  //addalarm("raw", time:seconds + max(30,ETAofTransfer - bt), "Transfer window", "Ready for transfer").
  add node(time:seconds + ETAofTransfer,0,0,dv).
  lock steering to prograde.
  abs(steeringManager:ANGLEERROR < 1).
  until ETAofTransfer < bt/2 {
    wait 1.
    set tAngVel to 360/target:obt:period.
    set sAngVel to 360/ship:obt:period.
    local targetAng to getTargetAngle().
    set angleChangeRate to abs(tAngVel-sAngVel).
    set ETAofTransfer to utilReduceTo360(getTargetAngle() - hohhmanLib:hohmanmTime()) / angleChangeRate.
    print "target angle=" at (40,5).
    print "eta to transfer=" at (40,6).
    print "Angle change rate=" at (40,7).
    print round(targetAng,1) at (80,5).
    print round(ETAofTransfer,1) at (80,6).
    print round(angleChangeRate,2) at (80,7).
    cancelWarpBeforeEta(ETAofTransfer, bt).
  }
}

function calculateReturnTransfer {
  parameter PE_GOAL is 50000.

  //Kerbin Arrival Orbit 
  local RET_AP to body:altitude + body:body:radius.
  local RET_PE to PE_GOAL + body:body:radius.
  local RET_SMA to (RET_PE+RET_AP)/2.
  local V_AP to sqrt(body:body:mu * (2/(RET_AP) - (1/RET_SMA))).
  //CURRENT DATAS
  local V_OBT to body:OBT:VELOCITY:ORBIT:MAG.
  local V_REL to V_OBT - V_AP.
  local R_PE is  periapsis +body:radius.
  local R_AP is  apoapsis +body:radius.
  local V_ESC to sqrt(2*body:mu / R_PE).
  local V_BO to sqrt(V_REL^2 + V_ESC^2).
  local V_CURRENT to VELOCITY:ORBIT:MAG.
  local DeltaV to V_BO - V_CURRENT.
  //HYPERBLOIC TRAJECTORY DATA
  local SMA_HYP is 1/(2/R_PE-(V_BO^2/body:mu)).
  local HYP_ECC is 1 - R_PE/SMA_HYP.
  //angle betwee dep asymptote and periapsis vector
  local A_ANGLE is ARCCOS(-1/HYP_ECC).
  local ORBIT_ANGLE is calcSignAngle().
  local PHASE_ETA is calcPhaseETA(A_ANGLE,ORBIT_ANGLE).

  if verbose {
    print "RET_AP:     " + RET_AP.
    print "RET_PE:     " + RET_PE.
    print "RET_SMA:     " + RET_SMA.
    print "V_AP:     " + V_AP.
    print "V_OBT:     " + V_OBT.
    print "V_REL:     " + V_REL.  
    print "R_PE:     " + R_PE.
    print "R_AP:     " + R_AP.
    print "V_ESC:     " + V_ESC.
    print "V_BO:     " + V_BO.
    print "V_CURRENT:     " + V_CURRENT.
    print "DeltaV:      " + DeltaV.
    print "SMA_HYP:     " + SMA_HYP.
    print "HYP_ECC:     " + HYP_ECC.
    print "A_ANGLE:       " +  A_ANGLE.
    print "PHASE_ETA:     " + PHASE_ETA.
    print "================================================".
  }
  return lexicon(
    "ang", A_ANGLE,
    "eta", PHASE_ETA,
    "dv", DeltaV
  ).
}

function calcSignAngle {
  local BODY_VEL_V is BODY:OBT:VELOCITY:ORBIT.
  local SHIP_V_V is SHIP:VELOCITY:ORBIT.
  local SHIP_P_V to body:position.
  local SHIP_N_V to vCrs(SHIP_P_V,SHIP_V_V):normalized.
  //signed Angle between body velocity and ship velocity vector
  LOCAL ANG to lngToDegrees(arcTan2(vDot(vCrs(SHIP_V_V,BODY_VEL_V),SHIP_N_V),vDot(SHIP_V_V,BODY_VEL_V))).
  //CLEARVECDRAWS().
  //drawVec(BODY_VEL_V,RED,"BODY_VEL_V").
  //drawVec(SHIP_V_V,BLUE,"SHIP_V_V").
  //drawVec(SHIP_N_V,WHITE,"SHIP_N_V").
  return ANG.
}

function calcPhaseETA {
  parameter targetAng.
  parameter currentAng.

  local shipAngularVelocity is 360/ship:orbit:period.
  return utilReduceTo360(targetAng - currentAng) / shipAngularVelocity.
}

function escapeTransfer {
  parameter PE_GOAL is 30000.
  
  local _transfer is calculateReturnTransfer(PE_GOAL).
  lock steering to prograde.
  wait until abs(steeringManager:ANGLEERROR < 1).
  local burnTime to burnTimeForDv(_transfer["dv"]).
  local PHASE_ETA is _transfer["eta"].

  addalarm("raw", time:seconds + max(30,PHASE_ETA - burnTime), "Return window", "Ready for transfer").

  local testnode to node(time:seconds + _transfer["eta"], 0, 0, _transfer["dv"]).
  add testnode.
  until (PHASE_ETA < burnTime/2) {
    local ORBIT_ANGLE is calcSignAngle().
    print "OBT_ANGLE:  " + ORBIT_ANGLE + "     " at (5,33).
    print "A_ANGLE:  " + _transfer["ang"] + "     "at (5,34).
    set PHASE_ETA to calcPhaseETA(_transfer["ang"],ORBIT_ANGLE).
    print "PHASE_ETA:  " + Round(PHASE_ETA) + "     " at (5,36).
    wait 1.
    cancelWarpBeforeEta(PHASE_ETA, burnTime).
  }

  wait until abs(steeringManager:ANGLEERROR < 1).

  printO("TRANSFER","Pályamódosítás megkezdése[DV]:"+_transfer["dv"]+"[BT]:"+burnTime).
  local th to 1.
  lock throttle to th.
  local DONE is false.
  local goalVelocity is _transfer["dv"]+ship:velocity:orbit:mag.
  local DVLeft is _transfer["dv"].
  until DVLeft < -0.1*_transfer["dv"] or DONE {
    set DVLeft to goalVelocity-SHIP:VELOCITY:ORBIT:mag.
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
  parameter PE_GOAL is max(body:atm:height * 1.2, body:radius*0.2).

  lock steering to prograde.
  wait until abs(steeringManager:ANGLEERROR < 1).
  local th is 1.
  lock throttle to th.
  printO("TRANSFER","Pályamódosítás megkezdése").
  local DONE is false.
  print "AP/TAP:" at (60,1).
  print "dv:" at (60,2).
  print "bt:" at (60,3).
  local dv is hohhmanLib:transferDeltaV().
  local velStart is ship:velocity:orbit:mag.
  //avoid body change before arrive
  local targetBody is target.
  until apoapsis > targetBody:apoapsis or DONE {
    local dvleft to (velStart + dv) - ship:velocity:orbit:mag.
    local bt is burnTimeForDv(dvleft).

    if obt:hasNextPatch {
      if obt:nextPatch = targetBody:obt {
        set th to bt/30.
        set DONE to obt:nextPatch:periapsis < PE_GOAL.
      }
    }else{
      set th to bt/10.
    }
    print round(dvleft,1) at (80,2).
    print round(bt,1) at (80,3).
    checkBoosters().
  }
  printO("TRANSFER","Pályamódosítás befejezve:"+ round(apoapsis)).
  unlock all.
}

function avoidCollision {
  printO("TRANSFER", "Elkerülő manőver.PE:" + periapsis).
  parameter minPer is max(body:atm:height * 1.2, body:radius*0.2).
  if periapsis < minPer {
    lock steering to heading (90,0).
    print steeringManager:ANGLEERROR.
    wait until abs(steeringManager:ANGLEERROR < 1).
    lock throttle to 1.
    until periapsis > minPer {
      if periapsis / minPer > 0.9 {
        lock throttle to max(0.05, 1-periapsis / minPer ).
      }
    }
    lock throttle to 0.

    printO("TRANSFER", "Elkerülő manőver befejezve.PE:" + periapsis).
  }
  wait 2.
}
