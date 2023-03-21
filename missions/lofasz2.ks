//KOS - transfer from lower orbit to higher to match
// the target body given.
// TODO: Try to find a way to tell which side of the destination
// I'm approaching - north, south, east, west, etc.

declare parameter destName.   // Name of destination body.
declare parameter destEncPe.  // Altitude of desired periapsis at body encounter.
declare parameter onlyFine. // Just skip to the fine tuning part if =1.
unlock all.

set destBod to Body(destName).

// Thrust to mass ratio, the max accelleration I can do:
lock maxacc to maxthrust/mass.

if onlyFine = 0 {
  clearscreen.
  print "Searching for transfer node.".

  set haOffset to 180.
  lock steering to prograde.

  run bruteForceNode(destBod).
  add bestGuess.

  // Using this instead of "prograde" or "retrograde"
  // so the code will function regardless of whether
  // the transfer is climbing up or down the gravity
  // well:
  set origVect to bestGuess:DELTAV.
  lock steering to origVect.


  set origETA to bestGuess:ETA.
  set waitStart to time:seconds.
  clearscreen.
  print "WAITING UNTIL MANEUVER TIME. Wait remaining:".
  set x to 0. until x > 18 { print "". set x to x + 1. }.
  lock timeleft to (waitStart+origETA) - time:seconds.
  // Don't allow timewarp to continue into the first velocity sampling:
  when timeleft < 3600*18 then {
    // Can't check for warp speed because bug
    // fix #230 from github isn't in release yet.
    // So I ASSUME warp is happening and stop it:
    set warp to 0.
    print "NEAR BURN TIME. WARP WITH CAUTION.".
  }.

  until timeleft <= 0 {
    print "(" +
	  floor(timeleft/86400) + "d" +
	  floor(mod(timeleft,86400)/3600) + "h" +
	  floor(mod(timeleft,3600)/60) + "m" +
	  floor(mod(timeleft,60)) + "s)   "  at (4,3).
    wait 1.
  }.

  set origDV to bestGuess:DELTAV:MAG.
  set origSpd to abs(velocity:orbit:MAG). // Yes I know MAG should never be negative, but I'm trying to find a bug.
  lock dvsofar to abs( abs(velocity:orbit:MAG) - origSpd).
  remove bestGuess.

  print "---- Transfer Burn ----" at (0,14).
  print "Total Guessed DV needed (m/s): " at (0,15).
  print    round(origDV,0) + "    " at (4,16).
  print "DV so far this burn (m/s): " at (0,17).
  print "orig spd = " + origSpd at (0,22).

  // Throttle is usually >=1 but will scale down as we get
  // close to the end.  Scales such that when the max accel
  // predicts there would be about 5 seconds left at
  // max thrust, that's when to slow down.
  lock myth to 0.05 + 0.2*(origDv-dvsofar)/maxacc .
  when abs(origDV) < abs(dvsofar) then { lock myth to 0.05. }. // sanity check if burn takes longer than thought.

  lock throttle to myth.

  // Now because we can't get the encounter node for NOW, I have to set a pointless manuever
  // node to test if there's an encounter:
  set encDone to 0.
  set thisEnc to 1*10^40. // bogus bignum
  set prevEnc to 1*10^40. // bogus bignum
  when (""+encounter) = destName then {
    set thisEnc to encounter:periapsis.
  }.

  set prevDCheck to time:seconds.
  set dummySet to 0.
  set overshot to 0.

  until encDone {
    wait 0.25. // helps keep kOS sane.
   
    print round(dvsofar,0) + "   " at (4,18).

    // If no fuel left, stage until there is:
    until maxthrust > 0 and stage:liquidfuel > 0 { stage. wait 0.25 . }.

    // How often to make a dummy node depends on how far into the 
    // burn we are.  Be kind to KSP and don't go wild making
    // lots of them and removing them until getting near the
    // end of the burn:
    if time:seconds > prevDCheck + (myth/3) {
      if dummySet { remove dummyN. }.
      // If it's not set far enough in the future it sometimes doesn't work:
      set dummyN to NODE(time:seconds+(myth*3),0,0,0).
      add dummyN.
      set dummySet to 1.
      set prevDCheck to time:seconds.
    }.

    // (""+encounter) forces it to cast it to a string regardless
    if (""+encounter) = destName {
      set thisEnc to encounter:periapsis.
      if thisEnc < 4*destEncPe or abs(dvsofar/origDV) > 0.90 {
	// This expression is designed to make it go slower when it's close:
	lock throttle to 0.01 + (abs(origDV-dvssofar) / 5*(maxthrust/mass) ).
      }.
      if prevEnc < thisEnc {
	// Not good enough, but it's starting to get worse
	// so this is the closest that is possible with a
	// dumb prograde burn at this distance.  This is
	// probably due to an inclination diff.
	lock throtte to 0.
	print "This is as close as I can get.".
	print "Encounter Pe is " + thisEnc + " m.".
	set encDone to 1.
      }.
      if thisEnc < destEncPe {
	lock throttle to 0.
	print "This is as close as I was told to get.".
	print "Encounter Pe is " + thisEnc + " m.".
	set encDone to 1.
      }.
      set prevEnc to encounter:periapsis.
    }.
    // If an encounter has occurred and now there isn't one,
    // then we overshot:
    if overshot = 0 and (""+encounter) = "None" and thisEnc < 1*10^40 {
      // Had an encounter and now don't anymore.
      print "OOPS OVERSHOT!  BACKING UP!" at (0,20).
      lock steering to (-1)*origVect.
      lock throttle to 0.
      wait 20.
      lock throttle to 0.01 . // go slow as we get close to the cutoff
      set overshot to 1.
    }.
  }.
  lock throttle to 0.
  print "WAIT HALF THE TIME TO TARGET. WAIT REMAINING:".
  print "".
  set period to 2*pi*sqrt(( ((apoapsis+periapsis)/2)+bodyRadius)^3 / (gConst*bodyMass) ).
  set endWait to time:seconds + period/4.
  remove dummyN.
  set stopped to 0.
  lock timeleft to endWait - time:seconds.
  until timeleft <= 0 {
    print "(" +
	  floor(timeleft/86400) + "d:" +
	  floor(mod(timeleft,86400)/3600) + "h:" +
	  floor(mod(timeleft,3600)/60) + "m:" +
	  floor(mod(timeleft,60)) + "s)   "  at (4,35).
    if timeleft < 100000 and stopped = 0 {
      set warp to 0.
      set stopped to 1.
    }.
    if timeleft < 60 and stopped = 1 {
      set warp to 0.
      set stopped to 2.
    }.
    wait 1.
  }.
}. // if onlyFine.

print "TESTING: Go normal or antinormal?".
set incBurn to NODE(time:seconds+20,0,0,0).
add incBurn.
set curPe to encounter:periapsis.
set incBurn:normal to 1.
// This mess is because the object type of "encounter"
// changes to a string when you deflect enough to make the encoutner go away:
set newPe to 0.
if (""+encounter) = "None" { set newPe to curPe + 99999999. }.
if newPe = 0 { set newPe to encounter:periapsis. }.
// Now newPe is either the periapsis after a DV of 1 in normal dir, or it's a big num if
// a DV of 1 in the normal direction causes the encounter to go away:
if newPe <= curPe { print "WILL BURN NORMAL.". set normDir to 1. }.
if newPe > curPe { print "WILL BURN ANTINORMAL.". set normDir to -1. }.
set incBurn:normal to normDir.
set mySteer to incBurn:DELTAV.
lock steering to mySteer.
wait 20.
remove incBurn.
set prevPe to curPe.
set encPe to curPe.
lock throttle to 0.05.
until encPe <= destEncPe or encPe > prevPe {
  wait 0.5. // Be nice to kOS which hates fast loops.
            // Also, the numbers wiggle enough that taking samples
	    // too quickly causes false positives when looking
	    // for a minimum.
  set prevPe to encPe.
  set dummyN to NODE(time:seconds+5,0,0,0).
  add dummyN.
  if (""+encounter) = "None" { set encPe to 9999999999. }.
  if  encPe < 9999999999 { set encPe to encounter:periapsis. }.
  remove dummyN.
}.
lock throttle to 0.
print "THAT'S AS GOOD AS I CAN GET.".
unlock steering.
unlock throttle.