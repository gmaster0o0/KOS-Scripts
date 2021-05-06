parameter verbose is true.

local vecDrawLex is lex().

function waitForStart {
  clearVecDraws().
  clearScreen.
  print "PRESS ABORT TO START LANDING!" at (30,10).
  wait until abort.
  set abort to false.
  sas off.
  lock steering to retrograde.
  clearScreen.
  createDisplay().
  wait 5.
}

//performing suicid burn in 2 step.
//1st is hard slow down until a hover alt
//2nd state is just hover and slowly touch down
function suicideBurn {
  parameter hoverSpeed is -1.

  local minAlt is 1.
  local breakingPID to PIDLOOP(0.5,0.1,0.05,0,1).
  breakingPID:reset().
  set breakingPID:SETPOINT to minALT.
  
  local th is 0.
  local st is srfRetrograde.
  lock throttle to th.
  lock steering to st.
  rcs on.
  panels off.
  gear on.

  local done to false.
  until done {
    print "SUICID BURN" at (60,0).
    print breakingPID:input at (60,10).
    local groundDistance is ship:bounds:bottomaltradar-minALT.
    local stopDist is calculateStoppingDistance().
    vecDrawAdd(vecDrawLex,ship:position,(verticalSpeed * up:vector/max(1,abs(verticalSpeed)/groundspeed)) - ship:velocity:surface,YELLOW,"BV").
    vecDrawAdd(vecDrawLex,ship:position,ship:velocity:surface,BLUE,"SV").
    vecDrawAdd(vecDrawLex,ship:position,(verticalSpeed * up:vector/max(1,abs(verticalSpeed)/groundspeed)),RED,"VS").
    set th to breakingPID:UPDATE(time:seconds,groundDistance - stopDist).
    set st to (verticalSpeed * up:vector/max(1,abs(verticalSpeed)/groundspeed)) - ship:velocity:surface.
    set done to groundDistance < minALT.
  }
  breakingPID:reset().
  set breakingPID:setpoint to hoverSpeed.
  lock steering to (up:vector*alt:radar) - ship:velocity:surface.
  until status = "LANDED"{
    vecDrawAdd(vecDrawLex,ship:position,(up:vector*20) - ship:velocity:surface,YELLOW,"BV").
    vecDrawAdd(vecDrawLex,ship:position,ship:velocity:surface,BLUE,"SV").
    vecDrawAdd(vecDrawLex,ship:position,(up:vector*20),RED,"VS").
    print "FINAL TOUCH     " at (60,0).
    print breakingPID:input at (60,10).
    set th to breakingPID:UPDATE(time:seconds,verticalSpeed).
    wait 0.
  }
  set th to 0.
  print "LANDED      " at (60,0).
  wait 2.
  unlock all.
  sas on.
  wait 5.
  panels on.
  rcs off.
}

function killhorizontalspeed {
  print "KILL HORIZONTAL SPEED" at (60,0).
  local th is 0.
  lock throttle to th.
  lock steering to verticalSpeed * up:vector - ship:velocity:surface.
  wait until steeringManager:ANGLEERROR < 1.

  local done is false.
  until done {
    local groundVelVec to vxcl(up:vector, ship:velocity:surface).
    set th to groundVelVec:mag / 10.
    fdata().
    set done to groundVelVec:mag < 3.
  }
}

local function createDisplay {
  if verbose {
    print "STATUS" at (40,0).
    print "verticalspeed" at (40,1).
    print "altRadar" at (40,2).
    print "maxAccUp" at (40,3).
    print "gravity" at (40,4).
    print "ffSpeed" at (40,5).
    print "impactTime" at (40,6).
    print "burningTime" at (40,7).
    print "breakingDistance" at (40,8).
    print "throttle" at (40,9).
    print "P_INP" at (40,10).
    print "SurfaceSpeed" at (40,12).
    print "Slope" at (40,13).
  }
}

//calc stopping distance. Basic kinetic EQs
local function calculateStoppingDistance {
  //t=v/a
  // d = 1/2 *a* t^2
  // d = (g/a)*h.
  local compensation is abs(cos(vang(up:vector, ship:facing:vector))).
  print compensation at (60,17).
  local groundVelVec is vxcl(up:vector, ship:velocity:surface).
  local stopDistanceX is groundVelVec:mag^2 / (2 * (ship:availablethrust/ship:mass)).
  local stopDistanceY is verticalSpeed^2 / (2 * maxAccUp())*(1/compensation).
  print stopDistanceX at (60,14).
  print stopDistanceY at (60,15).
  local stopDistance is sqrt(stopDistanceX^2+stopDistanceY^2).
    
  fdata(stopDistance).

  return stopDistance.
}

//display fligth data
local function fdata { 
  parameter stopDistance is "",
  bt is "",
  ffs is "".

  local groundVelVec is vxcl(up:vector, ship:velocity:surface).
  //local surfVelVec is ship:velocity:surface.
  if verbose {
    print verticalSpeed at (60,1).
    print ship:bounds:bottomaltradar at (60,2).
    print maxAccUp(altitude) at (60,3).
    print gravity(altitude) at (60,4).
    print ffs at (60,5).
    //print calcImpactTime() at (60,6).
    print bt at (60,7).
    print stopDistance at (60,8).
    print throttle at (60,9).
    print groundVelVec:mag at (60,12).
    print groundSlope() at (60,13).
    print vang(-up:vector, ship:velocity:surface) at (60,16).
  }

  //vecDrawAdd(vecDrawLex,ship:position,-up:vector*50,RED,"GVV").
  //vecDrawAdd(vecDrawLex,ship:position,ship:velocity:surface,BLUE,"velVec").
}

local function groundSlope {
  local center is ship:position.
  if ADDONS:TR:HASIMPACT {
    set center to ADDONS:TR:IMPACTPOS:position.
  }
  local tri is createTriangle(50,center).
  local a is body:geopositionOf(tri["north"]).
  local b is body:geopositionOf(tri["east"]).
  local c is body:geopositionOf(tri["west"]).

  local a_vec is a:altitudePosition(a:terrainHeight).
  local b_vec is b:altitudePosition(b:terrainHeight).
  local c_vec is c:altitudePosition(c:terrainHeight).

  vecDrawAdd(vecDrawLex,ship:position,a_vec,WHITE,"a_vec").
  vecDrawAdd(vecDrawLex,ship:position,b_vec,WHITE,"b_vec").
  vecDrawAdd(vecDrawLex,ship:position,c_vec,WHITE,"c_vec").

  local slopeNormVec is  vectorCrossProduct(c_vec - a_vec, b_vec - a_vec):normalized.
  return vang(slopeNormVec, center - body:position).
}

local function createTriangle {
  parameter height is 10.
  parameter center is ship:position.

  local east is vectorCrossProduct(north:vector, up:vector) * height * sin(60) .
  return lexicon(
    "north", center + height * north:vector,
    "east", center - height * cos(60) * north:vector + east,
    "west", center - height * cos(60) * north:vector - east
  
  ).
} 