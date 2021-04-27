function printO {
  parameter part.
  parameter msg.

  print "T+" + round(missionTime) + "["+ part + "]" + msg.
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
  print apoapsis at (80,1).
  print periapsis at (80,2).
  print altitude at (80,3).
  print ship:Q at (80,4).
}

function drawVec {
  parameter vec.
  parameter color.
  parameter title.
  parameter vectorSize is 0.5.

  local vecD TO VECDRAW(
    V(0,0,0),
    vec,
    color,
    title,
    vectorSize,
    TRUE,
    0.2,
    TRUE,
    TRUE
  ).
  return vecD.
}