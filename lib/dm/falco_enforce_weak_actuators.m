function [dm] = falco_enforce_weak_actuators(dm)

dm.VtoH(dm.weak) = dm.VtoHweak;

end

