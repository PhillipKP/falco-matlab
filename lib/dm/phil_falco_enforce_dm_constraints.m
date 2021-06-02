function [dm_command, dm] = phil_falco_enforce_dm_constraints(dm, flatmap)

% NEW CODE: Store for later use
original_dm_V = dm.V;

% NEW CODE: Convert flat map to voltages
dm_fm_V = flatmap ./ dm.VtoH;

% NEW CODE: Add flat map in voltage units instead of surface
% units
mp.dm.V = dm.V + dm_fm_V;

% NEW CODE For Simulating Pinned, Railed, and Stuck
% actuators in the full model
dm = falco_enforce_dm_constraints(dm);



% NEW CODE For Simulating Weak actuators in the full model
%mp.dm1 = falco_enforce_weak_actuators(mp.dm1);

%%% MODIFIED CODE: Flat map is baked into mp.dm1.V now
dm_command = dm.V.*dm.VtoH;   % DM1 commands in meters

% RESTORE mp.dm1.V to it's original value after
% this???
dm.Venf = dm.V; %dm.V is enforced
dm.V = original_dm_V; % I'm too scared I'll break something later so I restored the original dm.V

end