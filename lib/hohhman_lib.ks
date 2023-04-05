function HohhmanLib {

	local function hohhmanTransferDeltaV {
		parameter r1 is (ship:obt:semimajoraxis + ship:obt:semiminoraxis) / 2.
		parameter r2 is (target:obt:semimajoraxis + target:obt:semiminoraxis) / 2.
		parameter targetBody is "".

		if targetBody = ""  and hasTarget {
			set targetBody to target.
		}

		//print sqrt(body:mu/r1)*(sqrt((2*r2/(r1+r2)))-1).
		return sqrt(targetBody:mu / r1) * (sqrt( (2 * r2) / (r1 + r2) ) - 1).
	}

	local function hohhmanCircularizationDeltaV {
		parameter r1 is (ship:obt:semimajoraxis + ship:obt:semiminoraxis) / 2.
		parameter r2 is (target:obt:semimajoraxis + target:obt:semiminoraxis) / 2.

		return sqrt(body:mu / r2) * (1 - sqrt( (2 * r1) / (r1 + r2) )).
	}

	local function hohmanmTime {
		parameter r1 is ship:obt:semimajoraxis.
		parameter r2 is target:obt:semimajoraxis.

		local pt is 0.5 * ((r1 + r2) / (2 * r2)) ^ 1.5.
		local ft is pt - floor(pt).

		local theta is 360 * ft.

		local phi is 180 - theta.
		return phi.
	}
	
  return lexicon(
    "transferDeltaV",hohhmanTransferDeltaV@,
		"circularizationDeltaV",hohhmanCircularizationDeltaV@,
		"hohmanmTime",hohmanmTime@
  ).
}

