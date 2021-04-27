runPath("../lib/vecDraw_lib.ks").
runPath("../lib/utils_lib.ks").
clearVecDraws().
clearScreen.
local vecDrawLex is lexicon().

print "relTA:       " at (1,3).
print "TOTALDV:   " at (1,4).
print "NORMDV:   " at (1,5).
print "PRODV:   " at (1,6).
print "ETA:   " at (1,7).
local velVec is ship:velocity:orbit.
local posVec is ship:position - ship:body:position.
local normS is vCrs(velVec,posVec).

local TvelVec is minmus:velocity:orbit.
local TposVec is minmus:position - minmus:body:position.
local normT is vCrs(TvelVec,TposVec).
//vecDrawAdd(vecDrawLex,ship:position,velVec:normalized*10,RED,"Vel").
//vecDrawAdd(vecDrawLex,ship:position,posVec:normalized*10,GREEN,"Pos").
//vecDrawAdd(vecDrawLex,ship:position,normS:normalized*10,WHITE,"NormS").

//vecDrawAdd(vecDrawLex,ship:position,TvelVec:normalized*10,yellow,"TvelVec").
//vecDrawAdd(vecDrawLex,ship:position,TposVec:normalized*10,cyan,"TposVec").
//vecDrawAdd(vecDrawLex,ship:position,normT:normalized*10,blue,"NormT").


local relInc is vAng(normS,normT).
local ANvec is vCrs(normS,normT).

local srelTA is utilReduceTo360(signAngle(ANvec,posVec,normS:normalized)).

print srelTA at(10,3).

local etaTOAN is srelTA * (orbit:period/360). 

//vecDrawAdd(vecDrawLex,ship:body:position,ANvec:normalized*(body:radius + apoapsis),magenta,"ANvec").

function dvinc {
  parameter incl.
	parameter initVel.

	return 2 * initVel * sin (incl/2).
}

local dv is dvinc(relInc,velocityAt(ship,time:seconds + etaTOAN):orbit:mag).
local dvPro is dv * sin (relInc/2).
local dvNormal is dv * cos (relInc/2).
print dv at (10,4).
print dvNormal at (10,5).
print dvPro at (10,6).
print etaTOAN at (10,7).

if srelTA < 180 {
  set dvNormal to -1*dvNormal.
}
add node(time:seconds + etaTOAN, 0, dvNormal,-dvPro).

