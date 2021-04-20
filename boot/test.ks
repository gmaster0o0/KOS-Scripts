local th is 1.
lock steering to up.
lock throttle to th.
local targetAlt is 100.

wait until abort.
set abort to false.
stage.
.
until false {
  if alt:radar > targetAlt{
    set th to 0.
  }else{
    set th to 1.
  }
}