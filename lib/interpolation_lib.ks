//Linear interpolation for estimation 
//Data list is of x,y pairs
global InterpolationLib to ({
  local function linearInterpolation {
    parameter dataList.

    local valueNotFoundError is false.

    local function getValue {
      parameter xValue.
      local dataPoints is getClosestDataPoints(xValue).
      //Linear interpolation y = y1 + (y2-y1)/(x2-x1) * (x-x1)
      return dataPoints[0][1] + (xValue - dataPoints[0][0]) * (dataPoints[1][1] - dataPoints[0][1]) / (dataPoints[1][0] - dataPoints[0][0]).
    }

    local function getClosestDataPoints {
      parameter dataPoint.
      local index is 1.
      until index = dataList:length or dataList[index][0] > dataPoint {
        set index to index + 1.
      }
      if index < dataList:length {
        return list(dataList[index-1],dataList[index]).
      }
      set valueNotFoundError to true.
      //linear extrapolation if not found dataPoint in the list.
      return list(dataList[index-2],dataList[index-1]).
    }

    local function isNotFoundError {
      return valueNotFoundError.
    }

    return lexicon(
      "getValue",getValue@,
      "isNotFoundError", isNotFoundError@
    ).
  }

  // local function cubicSplineInterpolation {

  // }
  return lexicon(
    "linearInterpolation", linearInterpolation@
  ).
}):call().