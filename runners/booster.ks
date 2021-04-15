runOncePath("staging_lib").
runOncePath("ui_lib").

wait until not core:messages:empty.
set received to core:messages:pop.
if received:content = "undock" {
  printO("BOOSTER","Gyorsito raketa levalasztva").
  doSafeParachute().
}else{
  printO("BOOSTER","Nem ertelmezheto uzenet" + received:content).
}
