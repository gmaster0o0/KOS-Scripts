function isCloseTo {
	parameter targetNumber.
	parameter currentNumber.
	parameter threshold is 0.1.

	//print "threshold:  " + threshold + "      " at (5,24).
	//print "|" + round(targetNumber,3) + " - " + round(currentNumber,3) + "| < " + threshold at (5,25).
	return abs(targetNumber - currentNumber) < threshold.
}

function lngToDegrees {
  parameter lng.

  return mod(lng + 360, 360).
}

function getTargetAngle {
  return lngToDegrees(lngToDegrees(lngToDegrees(target:longitude) - lngToDegrees(ship:longitude))).
}

function utilReduceTo360 {
	parameter ang.
	return ang - 360 * floor(ang / 360).
}
function signAngle {
	parameter v1.
	parameter v2.
	parameter pn.
	return arcTan2(vDot(vCrs(v1,v2),pn),vDot(v1,v2)).
}
