% Copyright 2019, by the California Institute of Technology. ALL RIGHTS
% RESERVED. United States Government Sponsorship acknowledged. Any
% commercial use must be negotiated with the Office of Technology Transfer
% at the California Institute of Technology.
% -------------------------------------------------------------------------
%
% Function to compute the table in Sensitivities.csv, which is used to  
% compute the flux ratio noise (FRN) for the WFIRST CGI.
%
% REVISION HISTORY:
% - Created by A.J. Riggs on 2019-05-15.
% -------------------------------------------------------------------------

function tableSens = falco_FRN_Sens_table(mp)
    
%--First 3 columns (the easy, bookkeeping parts of the table)
Nmode = 21; %--Number of sensitivity types that the FRN calculator uses
Nann = size(mp.eval.Rsens,1); %--Number of annuli
tableSens = zeros(Nann*Nmode,4); %--Initialize
tableSens(:,1) = 0:(Nann*Nmode-1); %--overall index
tableSens(:,2) = repmat((0:(Nmode-1)).',[Nann,1]); %--sensmode
for ii=1:Nann;  tableSens((ii-1)*Nmode+1:ii*Nmode,3) = ii-1;  end %--annzone
% tableSens

%% Compute sensitivities to 1nm RMS of Zernikes Z2 to Z11
%     dE2mat = zeros;

mp.full.ZrmsVal = 1e-9; %--RMS values for each Zernike specified in vector indsZnoll [meters] 
mp.eval.indsZnoll = 2:11; %--Use tip/tilt through spherical modes

Zsens = falco_get_Zernike_sensitivities(mp); % dimensions of [Nzern,Nann]
for ii=1:Nann;  tableSens((ii-1)*Nmode+1:(ii-1)*Nmode+10,4) = Zsens(:,ii);  end %--Re-organize into column 4 of Sensitivities table

%% Compute sensitivities to 1 micron of X- and Y- Pupil Shear



end %--END OF FUNCTION