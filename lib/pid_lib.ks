global pidLip is ({
  local function pidVector {
    parameter kp, ki is 0, kd is 0, minOutput is 0, maxOutput is 0.
    
    //define pidloops for every coordinate
    local pidX is pidLoop(kp,ki,kd, minOutput, maxOutput).
    local pidY is pidLoop(kp,ki,kd, minOutput, maxOutput).
    local pidZ is pidLoop(kp,ki,kd, minOutput, maxOutput).

    local function setpoint{
      parameter valueVector.

      set pidX:setpoint to valueVector:X.
      set pidY:setpoint to valueVector:Y.
      set pidZ:setpoint to valueVector:Z.
    }

    local function update {
      parameter currentTime, value.

      return v(pidX:update(currentTime,value:x),pidY:update(currentTime,value:y),pidZ:update(currentTime,value:z)).
    }

    local function setMinOutput {
      parameter valueVector.

      set pidX:minoutput to valueVector:X.
      set pidY:minoutput to valueVector:Y.
      set pidZ:minoutput to valueVector:Z.
    }

    local function getMinOutput {
      return v(pidX:minoutput,pidY:minoutput,pidZ:minoutput).
    }

    local function setMaxOutput {
      parameter valueVector.

      set pidX:maxoutput to valueVector:X.
      set pidY:maxoutput to valueVector:Y.
      set pidZ:maxoutput to valueVector:Z.
    }

    local function setKP {
      parameter valueVector.

      set pidX:kp to valueVector:X.
      set pidY:kp to valueVector:Y.
      set pidZ:kp to valueVector:Z.
    }

    local function setKI {
      parameter valueVector.

      set pidX:ki to valueVector:X.
      set pidY:ki to valueVector:Y.
      set pidZ:ki to valueVector:Z.
    }

    local function setKD {
      parameter valueVector.

      set pidX:kd to valueVector:X.
      set pidY:kd to valueVector:Y.
      set pidZ:kd to valueVector:Z.
    }

    local function getMaxOutput {
      return v(pidX:maxoutput,pidY:maxoutput,pidZ:maxoutput).
    }
    //reset all pidloops
    local function reset {
      pidX:reset().
      pidY:reset().
      pidZ:reset().
    }

    local function getPidLoops {
      return lexicon(
        "X",pidX,
        "Y",pidY,
        "Z",pidZ
      ).
    }

    return lexicon(
      "setpoint",setpoint@,
      "update",update@,
      "setMinOutput",setMinOutput@,
      "getMinOutput", getMinOutput@,
      "setMaxOutput", setMaxOutput@,
      "getMaxOutput",getMaxOutput@,
      "getPidLoops",getPidLoops@,
      "setKP",setKP@,
      "setKI",setKI@,
      "setKD",setKD@,
      "reset",reset@
    ).
  }

  return lexicon("pidVector",pidVector@).
}):call().