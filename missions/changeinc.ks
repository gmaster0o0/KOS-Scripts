runPath("../lib/vecDraw_lib.ks").
runPath("../lib/utils_lib.ks").
runPath("../lib/wait_lib.ks").
runPath("../lib/rocket_utils_lib.ks").
runPath("../lib/ui_lib.ks").
runPath("../lib/staging_lib.ks").
runPath("../lib/node_lib.ks").

parameter targetInc is "".

clearVecDraws().
clearScreen.
removeNodes().
local vecDrawLex is lexicon().

local targetObj is minmus.

print "                    CHANGE ORBIT INCLINATION                           " at (20,0).
print "Status                               " at (60,1).
print "TA of AN               -          deg" at (60,2).
print "ETA:                                s" at (60,3).
print "velAtAn:                          m/s" at (60,4).
print "BT:                                 s" at (60,5).
print "burnVec:                          m/s" at (60,6).
print "relInc:                           deg" at (60,7).
print "throttle:                           %" at (60,8).

local relInc is 0.
local ETAto is 0.
local velAt is v(0,0,0).
local burnVec is v(0,0,0).
local bt is 0.
local th is 0.
local ANTA is 0.
lock throttle to th.

if hasTarget or targetInc = "" {
  set targetObj to target.

  set relInc to getRelInc().
  set ANTA to TAofANNode(ship,targetObj).
  set ETAto to ETAtoTA(ship:orbit,ANTA).
  set velAt to velocityAt(ship, ETAto + time:seconds):orbit.
  set burnVec to getBurnVector(ship,targetObj,ETAto).
  set bt to burnTimeForDv(burnVec:mag).
  
  print "Varunk a AN-ra"  at (80,1).
  print round(ANTA) at(80,2).
  print round(burnVec:mag,1) at(80,6).
  nodeFromVector(burnVec,ETAto + time:seconds + bt/2).
}else{
  set relInc to getRelInc().
  set ETAto to eta:apoapsis.
  set velAt to velocityAt(ship, ETAto + time:seconds):orbit.

  local dv is 2 * velAt:mag * sin (relInc/2).
  local nv is dv * cos(relInc/2).
  local pv is dv * -sin(relInc/2).  
  set burnVec to v(0,nv,pv).
  set bt to burnTimeForDv(burnVec:mag).
  print round(burnVec:mag,1) at(80,6).
  add node(ETAto + time:seconds + bt/2, 0, nv,pv). 
   
  print "Waiting for AP" at (80,1).
}

print round(ETAto,1) at (80,3). 
print round(velAt:mag,1) at (80,4).
print round(bt,1) at(80,5).
print round(relInc,2) at (80,7).
print round(th*100,2) at (80,8).

lock steering to burnVec.
wait until steeringManager:ANGLEERROR < 1.
addalarm("raw", time:seconds + max(30,ETAto - bt), "AN node", "change inc").
until ETAto < bt/2 {
  wait 1.
  if hasTarget or targetInc = "" {
    set ETAto to ETAtoTA(ship:orbit,ANTA).
  }else{
    set ETAto to eta:apoapsis.
  }
  print round(ETAto,1) at (80,3). 
}

printO("INC", "Palya modositas megkezdese:[DV:" + round(burnVec:mag,1)+ "][BT:"+round(bt,1) +"]").
local thPid is PIDLOOP(0.8,0.1,0.1,0,1).
set thPid:setpoint to 0.
local oldInc is abs(relInc).
local done is false.
until isCloseTo(0,oldInc,0.05) or done {
  set relInc to abs(getRelInc()).
  set th to thPid:update(time:seconds,-1*relInc).
  print round(relInc,2) at (80,7).
  print round(th*100,2) at (80,8).
  //avoid to increasing
  print relInc. 
  print oldInc.
  set done to relInc > oldInc.
  set oldInc to relInc.
  checkBoosters().
}
printO("INC", "Palya modositas befejezve").
set th to 0.

function getRelInc {
  if hasTarget or targetInc = "" {
    return relativeInc(ship,targetObj).
  }else{
    return targetInc - obt:inclination.
  }
}