% Copyright 2018-2021, by the California Institute of Technology.
% ALL RIGHTS RESERVED. United States Government Sponsorship acknowledged.
% Any commercial use must be negotiated with the Office
% of Technology Transfer at the California Institute of Technology.
% -------------------------------------------------------------------------
%
% Generate a simulated image in the specified subband.
%
% INPUTS
% ------
% mp : structure of model parameters
% iSubband : index of sub-bandpass for which to take the image
%
% OUTPUTS
% -------
% subbandImage : sub-bandpass image

function subbandImage = phil_falco_get_sim_sbp_image(mp, iSubband)


%iSubband = 1
%falco_get_sim_sbp_image_count = 1

%load(['falco_get_sim_sbp_image_iSuband_' num2str(iSubband) '_count_' num2str(falco_get_sim_sbp_image_count) '.mat'])



% global falco_get_sim_sbp_image_count
%
%
% save(['falco_get_sim_sbp_image_iSuband_' num2str(iSubband) '_count_' num2str(falco_get_sim_sbp_image_count) '.mat'])
%
% falco_get_sim_sbp_image_count = falco_get_sim_sbp_image_count + 1

% THIS PART WILL NEED TO BE DELETED!
%--Compute the DM surfaces outside the full model to save time
%     if any(mp.dm_ind == 1)
%         mp.dm1.surfM = falco_gen_dm_surf(mp.dm1, mp.dm1.dx, mp.dm1.NdmPad);
%     end
%     if any(mp.dm_ind == 2)
%         mp.dm2.surfM = falco_gen_dm_surf(mp.dm2, mp.dm2.dx, mp.dm2.NdmPad);
%     end
%     if any(mp.dm_ind == 9)
%         mp.dm9.phaseM = falco_dm_surf_from_cube(mp.dm9, mp.dm9);
%     end

%--Loop over all wavelengths and polarizations
Npol = length(mp.full.pol_conds);
indexComboArray = allcomb(1:mp.Nwpsbp, 1:Npol, 1:mp.star.count).'; % dimensions: [3 x mp.Nwpsbp*Npol*mp.star.count ]
Ncombos = size(indexComboArray, 2);

if mp.flagParfor
    parfor iCombo = 1:Ncombos
        Iall{iCombo} = falco_compute_subband_image_component(mp, indexComboArray, iCombo, iSubband);
    end
else
    for iCombo = Ncombos:-1:1
        
        % Extract indices
        iWavelength = indexComboArray(1, iCombo);
        iPol = indexComboArray(2, iCombo);
        iStar = indexComboArray(3, iCombo);
        
        % Compute E-field
        modvar.whichSource = 'star';
        modvar.sbpIndex = iSubband;
        modvar.wpsbpIndex = iWavelength;
        modvar.starIndex = iStar;
        mp.full.polaxis = mp.full.pol_conds(iPol); % used only in PROPER full models
        
        for dmi = 1:mp.NdmNoiseItr
        
            modvar.dmNoiseIndex = dmi;
            
            Estar_temp = model_full(mp, modvar);
            
            Istar_temp(:,:,dmi) = abs(Estar_temp).^2;
            
        end
        
        Istar_avg = mean(Istar_temp,3); 
        
        % NEW: NORMALIZE AFTER THE INTENSITY IS NORMALIZED!
        normFac = mp.Fend.full.I00(modvar.sbpIndex, modvar.wpsbpIndex); %--Value to normalize the PSF. Set to 0 when finding the normalization factor

        Istar_norm = 1/normFam * Istar_avg; 
        
        % Apply wavelength weight within subband.
        % Assume polarizations are evenly weighted.
        % OLD WAY:
        % Iout = mp.full.lambda_weights(iWavelength) / length(mp.full.pol_conds) * abs(Estar).^2;
       
        % NEW WAY: 
        Iout = mp.full.lambda_weights(iWavelength) / length(mp.full.pol_conds) * Istar_norm;
        
        
        Iall{iCombo} = Iout; %falco_compute_subband_image_component(mp, indexComboArray, iCombo, iSubband);
        
        
    end
end

%--Apply the spectral weights and sum
subbandImage = 0;
for iCombo = 1:Ncombos
    subbandImage = subbandImage + Iall{iCombo};
end

if mp.flagImageNoise
    subbandImage = falco_add_noise_to_subband_image(mp, subbandImage, iSubband);
end


end %--END OF FUNCTION


function Iout = falco_compute_subband_image_component(mp, indexComboArray, iCombo, iSubband)

% Generate the weighted, normalized intensity image for a single
% wavelength, polarization, and star in the specified subband.

% Extract indices
iWavelength = indexComboArray(1, iCombo);
iPol = indexComboArray(2, iCombo);
iStar = indexComboArray(3, iCombo);

% Compute E-field
modvar.whichSource = 'star';
modvar.sbpIndex = iSubband;
modvar.wpsbpIndex = iWavelength;
modvar.starIndex = iStar;
mp.full.polaxis = mp.full.pol_conds(iPol); % used only in PROPER full models



Estar = model_full(mp, modvar);



% Apply wavelength weight within subband.
% Assume polarizations are evenly weighted.
Iout = mp.full.lambda_weights(iWavelength) / length(mp.full.pol_conds) * abs(Estar).^2;

end %--END OF FUNCTION
