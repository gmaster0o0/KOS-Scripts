function hohmannDv {
	parameter r1 is (ship:obt:semimajoraxis + ship:obt:semiminoraxis) / 2.
	parameter r2 is (target:obt:semimajoraxis + target:obt:semiminoraxis) / 2.

	//return sqrt(body:mu / r2) * (1 - sqrt( (2 * r1) / (r1 + r2) )).
	return sqrt(body:mu / r1) * (sqrt( (2 * r2) / (r1 + r2) ) - 1).
}

function deltaVToPeriapsis {
  return hohmannDv(body:radius + periapsis,body:radius + apoapsis).
}

function hohhmanDVFromPeriod {
	parameter newPeriod.

	local newSemiMajorAxis is ((body:mu * newPeriod^2)/(4 * constant:pi))^(1/3).
  local newSemiMinorAxis is newSemiMajorAxis * sqrt(1-obt:eccentricity).
  local dv is hohmannDv((ship:orbit:semimajoraxis+ship:orbit:semiminoraxis)/2, (newSemiMajorAxis+newSemiMinorAxis)/2).

	return dv.
}

function hohmanmTime {
  local r1 is ship:obt:semimajoraxis.
	local r2 is target:obt:semimajoraxis.

	local pt is 0.5 * ((r1 + r2) / (2 * r2)) ^ 1.5.
	local ft is pt - floor(pt).

	// angular distance that target will travel during transfer
	local theta is 360 * ft.
	// necessary phase angle for vessel burn
	local phi is 180 - theta.
	return phi.
}