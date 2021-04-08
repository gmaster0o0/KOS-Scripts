function hohmannDv {
	parameter r1 is (ship:obt:semimajoraxis + ship:obt:semiminoraxis) / 2.
	parameter r2 is (target:obt:semimajoraxis + target:obt:semiminoraxis) / 2.

	return sqrt(body:mu / r1) * (sqrt( (2 * r2) / (r1 + r2) ) - 1).
}

function deltaVToPeriapsis {
  return hohmannDv(body:radius + periapsis,body:radius + apoapsis).
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