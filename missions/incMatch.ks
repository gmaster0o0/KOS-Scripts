runPath("../lib/vecDraw_lib.ks").
runPath("../lib/utils_lib.ks").
runPath("../lib/wait_lib.ks").
runPath("../lib/rocket_utils_lib.ks").
runPath("../lib/ui_lib.ks").
runPath("../lib/staging_lib.ks").

clearVecDraws().
clearScreen.
local vecDrawLex is lexicon().
local targetObj is minmus.
if hasTarget {
  set targetObj to target.
}

print "TA of AN   " at (1,2).
print "ETA:       " at (1,3).
print "velAtAn:   " at (1,4).
print "BT:        " at (1,5).
print "burnVec:   " at (1,6).
print "relInc:    " at (1,7).

local relInc is relativeInc(ship,targetObj).
print relInc at (15,7).
local ANTA is TAofANNode(ship,targetObj).
print ANTA at(15,2).
local etaTOAN is ETAtoTA(ship:orbit,ANTA).
print etaTOAN at (15,3). 
local velAtAN is velocityAt(ship, etaTOAN + time:seconds):orbit.
print velAtAN:mag at (15,4).
local burnVec is getBurnVector(ship,targetObj,etaTOAN).
print burnVec:mag at(15,6).
local bt is burnTimeForDv(burnVec:mag).
print bt at(15,5).

lock steering to burnVec.
local th is 0.
lock throttle to th.
printO("INC", "Varunk a AN-ra:" + etaTOAN).
until etaTOAN < bt/2 {
  set etaTOAN to ETAtoTA(ship:orbit,ANTA).
  print etaTOAN at (15,3).
}
printO("INC", "Palya modositas megkezdese:[DV:" + burnVec:mag+ "][BT:"+bt+"]").

local thPid is PIDLOOP(0.5,0.1,0.05,0,1).
set thPid:setpoint to 0.
until isCloseTo(0,relInc) {
  checkBoosters().
  print relInc at (15,7).
  set relInc to relativeInc(ship,targetObj).
  set th to thPid:update(time:seconds,-1*relInc).
}
printO("INC", "Palya modositas befejezve").
set th to 0.

