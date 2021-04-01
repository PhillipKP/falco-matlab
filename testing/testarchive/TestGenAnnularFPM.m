%---------------------------------------------------------------------------
% Copyright 2018-2021, by the California Institute of Technology. ALL RIGHTS
% RESERVED. United States Government Sponsorship acknowledged. Any
% commercial use must be negotiated with the Office of Technology Transfer
% at the California Institute of Technology.
%---------------------------------------------------------------------------
%% Test falco_gen_annular_FPM.m
%
% We define some tests for falco_gen_annular_FPM.m to test responses 
% different input parameters. 
classdef TestGenAnnularFPM < matlab.unittest.TestCase  
%% Properties
%
% A presaved file with FALCO parameters was saved and is lodaded to be used
% by methods. In this case we only use the mp.path.falco + lib/utils to
% addpath to utils functions to be tested.
%     properties
%         mp=Parameters();
%     end

%% Setup and Teardown Methods
%
%  Add and remove path to library functions to be tested.

    methods (TestClassSetup)
        function addPath(testCase)
            pathToFalco = fileparts(fileparts(fileparts(mfilename('fullpath')))); % falco-matlab directory;
            addpath(genpath([pathToFalco filesep 'lib']));
            addpath(genpath([pathToFalco filesep 'lib_external']));
        end
    end
    methods (TestClassTeardown)
        function removePath(testCase)
            pathToFalco = fileparts(fileparts(fileparts(mfilename('fullpath')))); % falco-matlab directory;
            rmpath(genpath([pathToFalco filesep 'lib']));
            addpath(genpath([pathToFalco filesep 'lib_external']));
        end
    end

%% Tests
%
%  Creates four tests:
%
% # *testOccSpotArea* verify that the area of the spot (circle) generated by
%                     falco_gen_annular_FPM.m is within 0.1% of the
%                     expected area.
% # *testOccSpotTranslation* verify that the the actual spot translation of
%                            the spot is equal to the expected translation.
% # *testAnnularOpeningArea* Verify that the are of the annular opening
%                            generated by falco_gen_annular_FPM.m is within
%                            0.1% of the expected area.
% # *testAnnularOpeningTranslation* Verify that the actual annular opening
%                                   translation is equal to the expected
%                                   translation.
    methods (Test)    
        function testOccSpotArea(testCase)
            inputs.pixresFPM = 6; %--pixels per lambda_c/D
            inputs.rhoInner = 3; % radius of inner FPM amplitude spot (in lambda_c/D)
            inputs.rhoOuter = inf; % radius of outer opaque FPM ring (in lambda_c/D)
            inputs.centering = 'pixel';
            inputs.xOffset = 5.5;
            inputs.yOffset = -10;
            spotOffset = falco_gen_annular_FPM(inputs);
            
            % Area test for circle
            areaExpected = pi*inputs.rhoInner^2*(inputs.pixresFPM^2);
            area = sum(1-spotOffset(:));
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance
            testCase.verifyThat(area, IsEqualTo(areaExpected,'Within', RelativeTolerance(0.001)))
        end
        function testOccSpotTranslation(testCase)
            inputs.pixresFPM = 6; %--pixels per lambda_c/D
            inputs.rhoInner = 3; % radius of inner FPM amplitude spot (in lambda_c/D)
            inputs.rhoOuter = inf; % radius of outer opaque FPM ring (in lambda_c/D)
            inputs.centering = 'pixel';
            spot = falco_gen_annular_FPM(inputs);
            
            %translation applied
            inputs.xOffset = 5.5;
            inputs.yOffset = -10; 
            spotOffset = falco_gen_annular_FPM(inputs);
           
            diff = pad_crop(spot, size(spotOffset), 'extrapval', 1) - circshift(spotOffset, -inputs.pixresFPM*[inputs.yOffset, inputs.xOffset]);
            testCase.verifyEqual(sum(abs(diff(:))), 0)             
        end
        function testAnnularOpeningArea(testCase)
            inputs.pixresFPM = 6; %--pixels per lambda_c/D
            inputs.rhoInner = 3; % radius of inner FPM amplitude spot (in lambda_c/D)
            inputs.rhoOuter = 10; % radius of outer opaque FPM ring (in lambda_c/D)
            % inputs.FPMampFac = 0; % amplitude transmission of inner FPM spot
            inputs.centering = 'pixel';
            %--Optional Inputs
            inputs.xOffset = 5.5;
            inputs.yOffset = -10;
            
            spotOffset = falco_gen_annular_FPM(inputs);
            
            % Area test for circle
            areaExpected = pi*(inputs.rhoOuter^2 - inputs.rhoInner^2)*(inputs.pixresFPM^2);
            area = sum(spotOffset(:));
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance
            testCase.verifyThat(area, IsEqualTo(areaExpected,'Within', RelativeTolerance(0.001)))
        end
        function testAnnularOpeningTranslation(testCase)
            inputs.pixresFPM = 6; %--pixels per lambda_c/D
            inputs.rhoInner = 3; % radius of inner FPM amplitude spot (in lambda_c/D)
            inputs.rhoOuter = 10; % radius of outer opaque FPM ring (in lambda_c/D)
            inputs.centering = 'pixel';
            spot = falco_gen_annular_FPM(inputs);
            
            %translation applied
            inputs.xOffset = 5.5;
            inputs.yOffset = -10;
            spotOffset = falco_gen_annular_FPM(inputs);
            
            diff = pad_crop(spot, size(spotOffset)) - circshift(spotOffset, -inputs.pixresFPM*[inputs.yOffset, inputs.xOffset]);
            testCase.verifyEqual(sum(abs(diff(:))), 0)             
        end
    end    
end
