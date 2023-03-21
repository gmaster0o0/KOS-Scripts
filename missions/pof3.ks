clearScreen.
runPath("../lib/utils_lib.ks").
runPath("../lib/ui_lib.ks").

local lowTargetOrbitRadius is 60000 + target:radius.
print "lowTargetOrbitRadius:         "+lowTargetOrbitRadius.
local lowKerbinOrbitRadius is kerbin:radius + 80000.
print "lowKerbinOrbitRadius:         " + lowKerbinOrbitRadius. 

local kerbinSMA is kerbin:obt:semimajoraxis.
print "kerbinSMA:                     "+kerbinSMA.
local targetSMA is target:obt:semimajoraxis .
print "targetSMA:                     "+targetSMA.
local transferOrbitSMA is (kerbinSMA+targetSMA)/2.
print "transferOrbitSMA:              "+transferOrbitSMA.
//craft speed when escape from kerbin SOI.
local v_dto_k is sqrt(sun:mu*(2/kerbinSMA - 1/transferOrbitSMA)).
print "v_dto_k:                       "+v_dto_k.

local v_dto_d is sqrt(sun:mu*(2/targetSMA - 1/transferOrbitSMA)).
print "v_dto_d:                       "+v_dto_d.
local v_kerbin is sqrt(sun:mu/kerbinSMA).
print "v_kerbin:                      "+v_kerbin.
local v_target is sqrt(sun:mu/targetSMA).
print "v_target:                      "+v_target.
local v_soi_k is v_dto_k - v_kerbin.
print "v_soi_k:                       "+v_soi_k.
local sma_dto_k is 1/(2/kerbin:soiradius - (v_soi_k^2)/kerbin:mu).
print "sma_dto_k:                     "+sma_dto_k.
local v_insertation is sqrt(kerbin:mu * (2/lowKerbinOrbitRadius - 1/sma_dto_k)).
print "v_insertation:                 "+v_insertation.
//local v_lko is sqrt(kerbin:mu/lowKerbinOrbitRadius).
local v_lko is ship:obt:velocity:obt:mag.
print "v_lko:                         "+v_lko.
local dv_dep is v_insertation - v_lko.
print "!!!dv_dep:                     "+dv_dep.
//capture velocity around duna orbit.
local v_soi_d is v_target - v_dto_d.
print "v_soi_d:                       "+v_soi_d.
local sma_dto_d is 1/(2/target:soiradius - (v_soi_d^2)/target:mu).
print "sma_dto_d:                     "+sma_dto_d.
local v_rendezvous is sqrt(target:mu *(2/lowTargetOrbitRadius - 1/sma_dto_d)).
print "v_rendezvous:                  "+v_rendezvous.
local v_ldo is sqrt(target:mu/lowTargetOrbitRadius).
print "v_ldo:                         "+v_ldo.
local dv_arrival is v_rendezvous - v_ldo.
print "!!!dv_arrival:                 "+dv_arrival.
local tof is constant:pi *  sqrt(transferOrbitSMA^3 / sun:mu).
print "tof:                           "+tof.
local phase_angle_target is 180-(tof / target:obt:period )*360.
print "!!!phase_angle_target:         " + phase_angle_target.
local ejection_angle is arcCos(-1/(1-lowKerbinOrbitRadius/sma_dto_k)).
print "!!!ejection_angle:             " + ejection_angle.
local relative_angle is getTargetAngle(ship:body,target).
print "relative_angle:                " + relative_angle.
local arrivalOrbitalAngularVelocity is 360/target:obt:period.
local currentAngularVelocity is 360 / ship:body:obt:period.               
local angleChangeRate is abs(arrivalOrbitalAngularVelocity - currentAngularVelocity).
print "angleChangeRate:               " + angleChangeRate.

local waitDuration is utilReduceTo360(relative_angle - phase_angle_target)/angleChangeRate.
print "waitDuration                   " + formatTS(waitDuration).
print "waitDuration                   "+  time(WaitDuration):full.
add node(time:seconds + WaitDuration,0,0,dv_dep).

local ORBIT_ANGLE is calcSignAngle().
print "ORBIT_ANGLE:" + ORBIT_ANGLE.
local PHASE_ETA is calcPhaseETA(ejection_angle,ORBIT_ANGLE).
print PHASE_ETA.
function calcPhaseETA {
  parameter targetAng.
  parameter currentAng.

  local shipAngularVelocity is 360/ship:orbit:period.
  return utilReduceTo360(targetAng - currentAng) / shipAngularVelocity.
}

function calcSignAngle {
  local BODY_VEL_V is BODY:OBT:VELOCITY:ORBIT.
  local SHIP_V_V is SHIP:VELOCITY:ORBIT.
  local SHIP_P_V to body:position.
  local SHIP_N_V to vCrs(SHIP_P_V,SHIP_V_V):normalized.
  //signed Angle between body velocity and ship velocity vector
  LOCAL ANG to lngToDegrees(arcTan2(vDot(vCrs(SHIP_V_V,BODY_VEL_V),SHIP_N_V),vDot(SHIP_V_V,BODY_VEL_V))).
  CLEARVECDRAWS().
  drawVec(BODY_VEL_V,RED,"BODY_VEL_V").
  drawVec(SHIP_V_V,BLUE,"SHIP_V_V").
  drawVec(SHIP_N_V,WHITE,"SHIP_N_V").
  return ANG.
}

// left-pad with zeroes. Assumes you want a length of 2 if not specified
FUNCTION padZ
{
  PARAMETER t, l IS 2.
  LOCAL s IS "" + t.
  UNTIL s:LENGTH >= l { SET s TO "0" + s. }
  RETURN s.
}

// returns elapsed time in the format "[T+YY-DDD HH:MM:SS]"
FUNCTION formatTS
{
  parameter ts.
  set ts to time(ts).
  RETURN "[T+" 
    + padZ(ts:YEAR) + "Y " // subtracts 1 to get years elapsed, not game year
    + padZ(ts:DAY,3) + "D " // subtracts 1 to get days elapsed, not day of year
    + padZ(ts:HOUR) + ":"
    + padZ(ts:MINUTE) + ":"
    + padZ(ROUND(ts:SECOND))+ "]".
}