% Copyright 2018, by the California Institute of Technology. ALL RIGHTS
% RESERVED. United States Government Sponsorship acknowledged. Any
% commercial use must be negotiated with the Office of Technology Transfer
% at the California Institute of Technology.
% -------------------------------------------------------------------------
%
% mp = falco_config_gen_chosen_apodizer(mp)
%
% Function to generate the apodizer representation based on configuration settings.
%
% 
% REVISION HISTORY:
% ----------------
% Created on 2018-05-29 by A.J. Riggs.

function mp = falco_config_gen_chosen_apodizer(mp)

switch lower(mp.coro)
    
	case{'lc','hlc','ehlc','fohlc'}
        disp('Using Lyot coronagraph without apodizer or aperture stop.')
	case{'roddier'}
        disp('Using Roddier coronagraph without apodizer or aperture stop.')
    case{'flc'}
        disp('Using spatially-filtered Lyot coronagraph without apodizer or aperture stop.')
    case{'splc','sphlc'}
        
        switch upper(mp.SPname)
                
            case{'SPC20170714','SPC-20170714','20170714'}
                load('WFIRST_CGI_apod_SPC_20170714.mat','SP'); %--Contains the 1001x1001 matrix named "SP"
                temp = zeros(ceil_even(length(SP)));
                temp(2:end,2:end) = SP;
                mp.P3.full.mask = temp;
                
                %--NOTE: ADD A PART HERE TO DOWNSAMPLE THE APODIZER
                mp.P3.compact.mask = temp;
                
            case{'SPC-RING','RING','1D'}
        
                mp.P3.full.mask = falco_gen_multi_ring_SP(mp.rEdgesLeft,mp.rEdgesRight,mp.P2.full.dx,mp.P2.D,mp.centering);
                
                %--Generate lower-resolution SP for the compact model
                mp.P3.compact.mask = falco_gen_multi_ring_SP(mp.rEdgesLeft,mp.rEdgesRight,mp.P2.compact.dx,mp.P2.D,mp.centering);
        
                if(mp.flagPlot)
                    figure(504); imagesc(padOrCropEven(mp.P3.full.mask,length(mp.P1.full.mask)) + mp.P1.full.mask); axis xy equal tight; colorbar;
                end
        end
        
        if(mp.full.flagPROPER==false)
            mp.P3.full.Narr= length(mp.P3.full.mask);
            mp.P3.full.dx = mp.P2.full.dx;
        end
        
        mp.P3.compact.dx = mp.P2.compact.dx;
        mp.P3.compact.Narr = length(mp.P3.compact.mask);

    case{'vortex','vc','avc'}
        
        %if(nnz(strcmp(mp.whichPupil,{'LUVOIRA5','LUVOIR_B_offaxis','HabEx_B_offaxis'}))>0 && mp.flagApod)
        if(mp.flagApod)
            % Full aperture stop 
            mp.P3.full.Narr = 2^(nextpow2(mp.P1.full.Nbeam));

            if(strcmp(mp.P3.apodType,'Simple'))
                inputs.Nbeam = mp.P1.full.Nbeam; % number of points across incoming beam 
                inputs.Npad = mp.P3.full.Narr;
                inputs.OD = mp.P3.ODnorm;
                inputs.ID = mp.P3.IDnorm;
                inputs.Nstrut = 0;
                inputs.angStrut = []; %Angles of the struts 
                inputs.wStrut = 0; % spider width (fraction of the pupil diameter)

                mp.P3.full.mask= falco_gen_pupil_Simple( inputs );

                % Compact aperture stop 
                inputs.Nbeam = mp.P1.compact.Nbeam; %--Number of pixels across the aperture or beam (independent of beam centering)
                inputs.Npad = 2^(nextpow2(mp.P1.compact.Nbeam)); 

                mp.P3.compact.Narr = 2^(nextpow2(mp.P1.compact.Nbeam));
                mp.P3.compact.mask = falco_gen_pupil_Simple( inputs );
            elseif (nnz(strcmp(mp.P3.apodType,'HCST_AVC'))>0 && mp.flagApod) 
                avc_mask = fitsread([mp.path.mask,'ApodizedPupil_HCST.fits']);
                mp.P3.full.mask = imresize(avc_mask,[mp.P3.full.Nbeam mp.P3.full.Nbeam]);
                mp.P3.full.Narr = mp.P3.full.Nbeam;
                mp.P3.compact.Narr = mp.P3.full.Narr;
                mp.P3.compact.mask = mp.P3.full.mask;
            elseif (nnz(strcmp(mp.P3.apodType,'HCST_AVC_unevenIllu'))>0 && mp.flagApod) 
                avc_mask = fitsread([mp.path.mask,'ApodizedPupil_unevenIllu_500.fits']);
                mp.P3.full.mask = imresize(avc_mask,[mp.P3.full.Nbeam mp.P3.full.Nbeam]);
                mp.P3.full.Narr = mp.P3.full.Nbeam;
                mp.P3.compact.Narr = mp.P3.full.Narr;
                mp.P3.compact.mask = mp.P3.full.mask;
                
            else
                if(exist(mp.P3.apodType,'file')~=2)
                    disp('Specified apodizer not supported.');
                else
                    [~,~,ext] = fileparts(mp.P3.apodType);
                    if(strcmpi(ext,'.fits'))
                        APOD = fitsread(mp.P3.apodType);
                    else
                        % Assumes mp.P3.apodType is a .mat file and the variable name is APOD
                        load(mp.P3.apodType)
                    end
                    mp.P3.full.mask = padOrCropEven(APOD,mp.P3.full.Narr);
                    mp.P3.compact.Narr = mp.P3.full.Narr;
                    mp.P3.compact.mask = mp.P3.full.mask;
                end
            end
            
        
        else
            disp('Using vortex without apodizer or aperture stop.')
        end
        
	case{'aplc'}
        
        if(~strcmpi(mp.centering,'pixel'))
            error('Use pixel centering for APLC');
        end
        if(mp.P1.full.Nbeam~=mp.P1.compact.Nbeam)
            error('APLC currently requires Nbeam for the full and compact.');
        end

        mp.P3.full.mask = falco_gen_tradApodizer(mp.P1.full.mask,mp.P1.full.Nbeam,mp.F3.Rin,(1+mp.fracBW/2)*mp.F3.Rout,mp.useGPU);
        mp.P3.full.Narr = length(mp.P3.full.mask);
        
        mp.P3.compact.mask = mp.P3.full.mask;
        mp.P3.compact.Narr = length(mp.P3.compact.mask);
        
        mp.P3.full.dx = mp.P2.full.dx;
        mp.P3.compact.dx = mp.P2.compact.dx;
        
        if(mp.flagPlot)
            figure(504); imagesc(padOrCropEven(mp.P3.full.mask,length(mp.P1.full.mask)).*mp.P1.full.mask); axis xy equal tight; colorbar;
        end

    otherwise
        error([mp.coro,' is not a valid option for mp.coro.']);
end

end %--END OF FUNCTION