function speedLimit {
  parameter maxSpeed.
  if SHIP:AIRSPEED > maxSpeed  {
      return throttle* 0.9.
  }
  return 1.
}

function apoapsLimit {
  parameter goalALT.

  if apoapsis > goalALT  {
    return 0.
  }
  return 1.
}

function runTest {
  Ship:partstagged("test")[0]:getmodule("moduletestsubject"):doevent("run test").
}

function spashDownMission {
  parameter test is false.

  local th to 1.
  lock throttle to th. 

  if test {
    if Ship:partstagged("test"):length = 0 {
      printO("testMission","NO part with TEST tag").
    }
  }
  lock steering to heading(90, 45 ).
  if status = "PRELAUNCH" {
    doSafeStage().
  }

  until status = "LANDED" or status = "SPLASHED" {
    if checkEngines(){
      if NOT CHUTESSAFE {
          printO("parachute","parachute activated").
          CHUTESSAFE ON.
      }
    }
    print "STATUS:   " + SHIP:STATUS + "      " at (5,25).
    print "ALTITUDE:   " + SHIP:ALTITUDE + "      " at (5,26).
  }
  wait 5.
  if test {
    runTest().
  }else{
    doSafeStage().
    doSafeStage().
  }
}

function haulMission {
  printO("haulMission","Starting").
  local finished to false.
  parameter goalALT.
  parameter maxSpeed is 0.

  local th to 1.
  lock throttle to th. 
  LOCK STEERING TO UP.
  doSafeStage().

  until finished {
    if maxSpeed = 0 {
      set th to apoapsLimit(goalALT).
    }else{
      set th to speedLimit(maxSpeed).
    }
    if(SHIP:ALTITUDE > goalALT){
      set finished to true.
    }
  }
  set th to 0.

  printO("haulMission","Finished").
  doSafeParachute().
}

function testMission {
  parameter maxSpeed.
  parameter goalALT.
  parameter test is false.

  local th to 1.
  lock throttle to th. 
  if test{
    if Ship:partstagged("test"):length = 0 {
      printO("testMission","NO part with TEST tag").
    }
  }
  printO("testMission","Starting").
  local finished to false.

  LOCK STEERING TO UP.
  doSafeStage().

  until finished {
    if maxSpeed = 0 {
      set th to apoapsLimit(goalALT).
    }else{
      set th to speedLimit(maxSpeed).
    }
    if(SHIP:ALTITUDE > goalALT){
      if(test){
        runTest().
      }else {
        doSafeStage().
      }
      set finished to true.
    }
  }
  set th to 0.

  printO("testMission","Finished").
  doSafeParachute().
}
