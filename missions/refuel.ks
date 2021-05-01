runPath("../lib/refuel_lib.ks").

parameter resTag is "rout".

clearScreen.

print "Status:         " at (5,4).
print "CurrentResouce: " at (5,5).
print "Transfered:     " at (5,6).

local resTransfers is createResouceTransfers(resTag).

for r in resTransfers {
  executeResouceTransfer(r).
}
