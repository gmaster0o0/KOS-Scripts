function printO {
  parameter part.
  parameter msg.

  print "T+" + round(time:seconds) + "["+ part + "]" + msg.
}

function countDown {
  parameter count is 10.

  from {local i is count.} until i=0 step {set i to i-1.} do {
    hudtext(i, 1.2,4,100,RED,false).
    wait 1.
  }
  hudtext("LAUNCH", 1.2,4,100,GREEN,false).
}

function flightData {
  print apoapsis at (15,1).
  print periapsis at (15,2).
  print altitude at (15,3).
}