% Copyright 2018, by the California Institute of Technology. ALL RIGHTS
% RESERVED. United States Government Sponsorship acknowledged. Any
% commercial use must be negotiated with the Office of Technology Transfer
% at the California Institute of Technology.
% -------------------------------------------------------------------------
%
% mp = falco_config_gen_chosen_LS(mp)
%
% Function to generate the Lyot stop representation based on configuration settings.
%
% REVISION HISTORY:
% ----------------
% Created on 2018-05-29 by A.J. Riggs.

function mp = falco_config_gen_chosen_LS(mp)

%% Lyot plane resolution, coordinates, and cropped-down mask for compact model

%--Resolution at Lyot Plane
if(mp.full.flagPROPER==false)
    mp.P4.full.dx = mp.P4.D/mp.P4.full.Nbeam;
end
% switch mp.layout
%     case{'wfirst_phaseb_simple','wfirst_phaseb_proper'}
%         
%     otherwise
%         mp.P4.full.dx = mp.P4.D/mp.P4.full.Nbeam;
% end
mp.P4.compact.dx = mp.P4.D/mp.P4.compact.Nbeam;

switch upper(mp.whichPupil)
    case{'SIMPLE','SIMPLEPROPER','DST_LUVOIRB','ISAT'}
        
        if(strcmpi(mp.whichPupil,'SIMPLEPROPER'));  inputs.flagPROPER = true;  end
        inputs.Nbeam = mp.P4.full.Nbeam; % number of points across incoming beam 
        inputs.Npad = 2^(nextpow2(mp.P4.full.Nbeam));
        inputs.OD = mp.P4.ODnorm;
        inputs.ID = mp.P4.IDnorm;
        inputs.Nstrut = mp.P4.Nstrut;
        inputs.angStrut = mp.P4.angStrut; % Angles of the struts 
        inputs.wStrut = mp.P4.wStrut; % spider width (fraction of the pupil diameter)

        mp.P4.full.mask = falco_gen_pupil_Simple(inputs);
        
        inputs.Nbeam = mp.P4.compact.Nbeam; %--Number of pixels across the aperture or beam (independent of beam centering)
        inputs.Npad = 2^(nextpow2(mp.P4.compact.Nbeam));
        
        mp.P4.compact.mask = falco_gen_pupil_Simple(inputs);
 
    case{'WFIRST180718'}

        %--Define Lyot stop generator function inputs for the 'full' optical model
        changes.ID = mp.P4.IDnorm;
        changes.OD = mp.P4.ODnorm;
        changes.wStrut = mp.P4.wStrut;
        changes.flagRot180 = true;

        if(mp.full.flagPROPER==false)
            mp.P4.full.mask = falco_gen_pupil_WFIRST_CGI_180718(mp.P4.full.Nbeam,mp.centering,changes);
        end

        %--Make or read in Lyot stop (LS) for the 'compact' model
        mp.P4.compact.mask = falco_gen_pupil_WFIRST_CGI_180718(mp.P4.compact.Nbeam,mp.centering,changes);

        if(isfield(mp,'LSshape'))
            switch lower(mp.LSshape)
                case 'bowtie'
                    %--Define Lyot stop generator function inputs in a structure
                    inputs.Dbeam = mp.P4.D; % meters;
                    inputs.ID = mp.P4.IDnorm; % (pupil diameters)
                    inputs.OD = mp.P4.ODnorm; % (pupil diameters)
                    inputs.ang = mp.P4.ang; % (degrees)
                    inputs.centering = mp.centering; % 'interpixel' or 'pixel'

                    if(mp.full.flagPROPER==false)
                        inputs.Nbeam = mp.P4.full.Nbeam; 
                        mp.P4.full.mask = falco_gen_bowtie_LS(inputs);
                    end
                    
                    %--Make bowtie Lyot stop (LS) for the 'compact' model
                    inputs.Nbeam = mp.P4.compact.Nbeam; 
                    mp.P4.compact.mask = falco_gen_bowtie_LS(inputs);    
            end
        end
        
    case{'WFIRST_ONAXIS'}
        
         %--Define Lyot stop generator function inputs for the 'full' optical model
        inputs.Nbeam = mp.P4.full.Nbeam;     % number of points across incoming beam  
        inputs.Dbeam = mp.P4.D; %--diameter of the beam at the mask (meters)
        inputs.ID = mp.P4.IDnorm;
        inputs.OD = mp.P4.ODnorm;
        inputs.wStrut = mp.P4.wStrut;
        inputs.centering = mp.centering;

        %--Make or read in Lyot stop (LS) for the 'full' model
        mp.P4.full.mask = falco_gen_pupil_WFIRSTcycle6_LS(inputs,'ROT180');

        %--Make or read in Lyot stop (LS) for the 'compact' model
        inputs.Nbeam = mp.P4.compact.Nbeam; % number of points across incoming beam           
        mp.P4.compact.mask = falco_gen_pupil_WFIRSTcycle6_LS(inputs,'ROT180');
        
        if(isfield(mp,'LSshape'))
            switch lower(mp.LSshape)
                case 'bowtie'
                    %--Define Lyot stop generator function inputs in a structure
                    inputs.Dbeam = mp.P4.D; % meters;
                    inputs.Nbeam = mp.P4.full.Nbeam; 
                    inputs.ID = mp.P4.IDnorm; % (pupil diameters)
                    inputs.OD = mp.P4.ODnorm; % (pupil diameters)
                    inputs.ang = mp.P4.ang; % (degrees)
                    inputs.centering = mp.centering; % 'interpixel' or 'pixel'

                    %--Make bowtie Lyot stop (LS) for the 'full' model
                    mp.P4.full.mask = falco_gen_bowtie_LS(inputs);

                    %--Make bowtie Lyot stop (LS) for the 'compact' model
                    inputs.Nbeam = mp.P4.compact.Nbeam; 
                    mp.P4.compact.mask = falco_gen_bowtie_LS(inputs);               
            end
        end
        
    case{'LUVOIRAFINAL'}
    
        %--Define Lyot stop generator function inputs for the 'full' optical model
        inputs.Nbeam = mp.P4.full.Nbeam; % number of points across incoming beam  
        inputs.Dbeam = mp.P1.D;
        inputs.ID = mp.P4.IDnorm;
        inputs.OD = mp.P4.ODnorm;
        inputs.wStrut = mp.P4.wStrut;
        inputs.centering = mp.centering;
        %--Make or read in Lyot stop (LS) for the 'full' model
        mp.P4.full.mask = falco_gen_pupil_LUVOIR_A_final_Lyot(inputs,'ROT180');
        
        %--Make or read in Lyot stop (LS) for the 'compact' model
        inputs.Nbeam = mp.P4.compact.Nbeam;     % number of points across incoming beam           
        mp.P4.compact.mask = falco_gen_pupil_LUVOIR_A_final_Lyot(inputs,'ROT180');
    
	case{'LUVOIRA5','LUVOIRA0'}
        
        %--Define Lyot stop generator function inputs for the 'full' optical model
        inputs.Nbeam = mp.P4.full.Nbeam; % number of points across incoming beam  
        inputs.Dbeam = mp.P1.D;
        inputs.ID = mp.P4.IDnorm;
        inputs.OD = mp.P4.ODnorm;
        inputs.wStrut = mp.P4.wStrut;
        inputs.centering = mp.centering;
        %--Make or read in Lyot stop (LS) for the 'full' model
        mp.P4.full.mask = falco_gen_pupil_LUVOIR_A_5_Lyot_struts(inputs,'ROT180');
        
        %--Make or read in Lyot stop (LS) for the 'compact' model
        inputs.Nbeam = mp.P4.compact.Nbeam;     % number of points across incoming beam           
        mp.P4.compact.mask = falco_gen_pupil_LUVOIR_A_5_Lyot_struts(inputs,'ROT180');
        
    case {'LUVOIR_B_OFFAXIS','HABEX_B_OFFAXIS'}
        %--Full model
        inputs.Nbeam = mp.P4.full.Nbeam; % number of points across incoming beam 
        inputs.Npad = 2^(nextpow2(mp.P4.full.Nbeam));
        inputs.OD = mp.P4.ODnorm;
        inputs.ID = mp.P4.IDnorm;
        inputs.Nstrut = 0;
        inputs.angStrut = []; % Angles of the struts 
        inputs.wStrut = 0; % spider width (fraction of the pupil diameter)

        mp.P4.full.mask = falco_gen_pupil_Simple(inputs);
        
        pad_pct = mp.P4.padFacPct;
        if(pad_pct>0) %--Also apply an eroded/padded version of the segment gaps

            pupil0 = mp.P1.full.mask;
            Nbeam = inputs.Nbeam;
            Npad = inputs.Npad;

            xsD = (-Npad/2:(Npad/2-1))/Nbeam; %--coordinates, normalized to the pupil diameter
            [XS,YS] = meshgrid(xsD);
            RS = sqrt(XS.^2 + YS.^2);
        
            pupil1 = 1-pupil0;

            spot = zeros(Npad);
            spot(RS <= pad_pct/100) = 1;

            pupil4 = ifftshift(ifft2(fft2(fftshift(pupil1)).*fft2(fftshift(spot))));
            pupil4 = abs(pupil4);
            pupil4 = pupil4/max(pupil4(:));

            pupil5 = 1-pupil4;

            thresh = 0.99;
            pupil5(pupil5<thresh) = 0;
            pupil5(pupil5>=thresh) = 1;

            mp.P4.full.mask = mp.P4.full.mask.*pupil5;            
        end
        
        %--Compact model
        inputs.Nbeam = mp.P4.compact.Nbeam; %--Number of pixels across the aperture or beam (independent of beam centering)
        inputs.Npad = 2^(nextpow2(mp.P4.compact.Nbeam));
        
        mp.P4.compact.mask = falco_gen_pupil_Simple(inputs);
        
        if(pad_pct>0) %--Also apply an eroded/padded version of the segment gaps
            pupil0 = mp.P1.compact.mask;
            Nbeam = inputs.Nbeam;
            Npad = inputs.Npad;

            xsD = (-Npad/2:(Npad/2-1))/Nbeam; %--coordinates, normalized to the pupil diameter
            [XS,YS] = meshgrid(xsD);
            RS = sqrt(XS.^2 + YS.^2);

            pupil1 = 1-pupil0;

            spot = zeros(Npad);
            spot(RS <= pad_pct/100) = 1;

            pupil4 = ifftshift(ifft2(fft2(fftshift(pupil1)).*fft2(fftshift(spot))));
            pupil4 = abs(pupil4);
            pupil4 = pupil4/max(pupil4(:));

            pupil5 = 1-pupil4;

            thresh = 0.99;
            pupil5(pupil5<thresh) = 0;
            pupil5(pupil5>=thresh) = 1;

            mp.P4.compact.mask = mp.P4.compact.mask.*pupil5;
        end
end

%% Crop down the Lyot stop(s) to get rid of extra zero padding for the full model
switch upper(mp.coro)
    case{'VORTEX','VC','AVC'}
        mp.P4.full.Narr = length(mp.P4.full.mask);
        mp.P4.full.croppedMask = mp.P4.full.mask;
        mp.P4.compact.Narr = length(mp.P4.compact.mask);
        mp.P4.compact.croppedMask = mp.P4.compact.mask;
    otherwise
        if(mp.full.flagPROPER==false)
            %--Crop down the high-resolution Lyot stop to get rid of extra zero padding
            LSsum = sum(mp.P4.full.mask(:));
            LSdiff = 0; counter = 2;
            while(abs(LSdiff) <= 1e-7)
                mp.P4.full.Narr = length(mp.P4.full.mask)-counter;
                LSdiff = LSsum - sum(sum(padOrCropEven(mp.P4.full.mask, mp.P4.full.Narr-2))); %--Subtract an extra 2 to negate the extra step that overshoots.
                counter = counter + 2;
            end
            mp.P4.full.croppedMask = padOrCropEven(mp.P4.full.mask,mp.P4.full.Narr); %--The cropped-down Lyot stop for the full model. 
        end

        % --Crop down the low-resolution Lyot stop to get rid of extra zero padding. Speeds up the compact model.
        LSsum = sum(mp.P4.compact.mask(:));
        LSdiff = 0; counter = 2;
        while(abs(LSdiff) <= 1e-7)
            mp.P4.compact.Narr = length(mp.P4.compact.mask)-counter; %--Number of points across the cropped-down Lyot stop
            LSdiff = LSsum - sum(sum(padOrCropEven(mp.P4.compact.mask, mp.P4.compact.Narr-2))); %--Subtract an extra 2 to negate the extra step that overshoots.
            counter = counter + 2;
        end
        mp.P4.compact.croppedMask = padOrCropEven(mp.P4.compact.mask,mp.P4.compact.Narr); %--The cropped-down Lyot stop for the compact model
end

%--(METERS) Lyot plane coordinates (over the cropped down to Lyot stop mask) for MFTs in the compact model from the FPM to the LS.
if(strcmpi(mp.centering,'interpixel') )
    mp.P4.compact.xs = (-(mp.P4.compact.Narr-1)/2:(mp.P4.compact.Narr-1)/2)*mp.P4.compact.dx;
else
    mp.P4.compact.xs = (-mp.P4.compact.Narr/2:(mp.P4.compact.Narr/2-1))*mp.P4.compact.dx;
end
mp.P4.compact.ys = mp.P4.compact.xs.';

end %--END OF FUNCTION