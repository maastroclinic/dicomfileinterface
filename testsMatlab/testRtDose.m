classdef testRtDose < matlab.unittest.TestCase
    
    properties
        % BasePath should be the path to the folder containing the CT, RTSTRUCT and RTDOSE folders
        BasePath = 'D:\TestData\12345'
        %path to refAxis mat file
        refAxisPath = 'refAxis.mat';
        refDosePath = 'refDoseValues.mat'
        RTDoseFile   = 'FO-3153671375338877408_v2.dcm';
        
        PERCISION = 0.0001;
        oldPath; 
        calcGrid;
        RTDose;
        
        % verification values
        REF_DOSE;
        REF_AXIS; 
    end
    
    methods (TestClassSetup)
        function setupOnce(me)
            
            ct = Ct(fullfile(me.BasePath, 'CT'), 'folder', false);
            me.calcGrid = CalculationGrid(ct, 'ct');    
            me.RTDose       = read_dicomrtdose(fullfile(me.BasePath, 'RTDOSE' , me.RTDoseFile));
            
            load(fullfile(me.BasePath, me.refAxisPath));
            me.REF_AXIS = refAxis;
            
            load(fullfile(me.BasePath, me.refDosePath));
            me.REF_DOSE = DoseValues;
        end
    end    

    methods(Test)
        function testConstructor(me)
            rtDose = RtDose(me.RTDose, me.calcGrid);
            verifyEqual(me, rtDose.fittedDoseCube, me.REF_DOSE, 'AbsTol', me.PERCISION);
        end
        
        function testConstructorFileName(me)
            rtDose = RtDose(fullfile(me.BasePath, 'RTDOSE' , me.RTDoseFile), me.calcGrid);
            verifyEqual(me, rtDose.fittedDoseCube, me.REF_DOSE, 'AbsTol', me.PERCISION);
        end
        
        function testFileLoadError(me)
            try
                RtDose(fullfile(me.BasePath, 'ERROR' , me.RTDoseFile), me.calcGrid);
            catch EM
                verifyEqual(me, 'Matlab:FileNotFound', EM.identifier)
            end
        end
        
        function testDoseIsNot3d(me)
            brokenDose = me.RTDose;
            brokenDose.Is3DDoseMap = 0;
            try
                RtDose(brokenDose, me.calcGrid);
            catch EM
                verifyEqual(me, 'RtDose:ErrorRescalingDose', EM.identifier)
            end
        end
    end
    
end
