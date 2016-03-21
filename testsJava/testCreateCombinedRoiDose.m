classdef testCreateCombinedRoiDose < matlab.unittest.TestCase
    properties
        
        % Locations of test files
        % BasePath should be the path to the folder containing the CT, RTSTRUCT and RTDOSE folders
        BasePath = 'D:\TestData\12345'
        % Filenames should hold the filename of the RTSTRUCT file and RTDOSE file
        RTStructFile = 'FO-4073997332899944647.dcm';
        RTDoseFile   = 'FO-3153671375338877408_v2.dcm';
        RTPlanFile   = 'FO-3630512758406762316.dcm';
        REF_DVH      = 'refDvhVector.mat'

        %wrapper operation instructions
        VOLUME_OPERATION = 'volume';
        DOSE_OPERATION   = 'dose';
        DVH_V_OPERATION             = 'dvh-v[perc|gy]';
        DVH_V_ABS_OPERATION         = 'dvh-v[cc|gy]';
        DVH_D_ABS_OPERATION         = 'dvh-d[gy|cc]';
        DVH_D_OPERATION             = 'dvh-d[gy|perc]';
        DVH_PERC_D_ABS_OPERATION    = 'dvh-d[perc|cc]';
        DVH_PERC_D_OPERATION        = 'dvh-d[perc|perc]';
        DVH_EXPORT_OPERATION        = 'dvh-curve';
        DVH_EXPORT_ABS_OPERATION    = 'dvh-curve-abs';
        TARGET_PRESCRIPTION_DOSE    = 45;
        RTVOLUME_EXPORT  = 'export';
        DVH_BINSIZE      = 1 %Gy
        
        doseOperations = [];
        requiredOutput = [];
        
        % Results
        volumeGTV1 = 57.7583;
        volume48GyGTV1 = 70.5122;
        dose2PercentGTV1 = 49.9198; 
        doseMinGTV1 = 45.4715;
        doseMaxGTV1 = 50.7382;
        doseMeanGTV1 = 48.3759;
        volumeGTV2 = 178.9627;
        volume48GyGTV2 = 7.9438;
        dose2PercentGTV2 = 48.5947;
        doseMinGTV2 = 42.3714;
        doseMaxGTV2 = 49.7521;
        doseMeanGTV2 = 46.5160;
        volumeSum = 236.6924;
        volume48GySum = 23.2092;
        dose2PercentSum = 49.40467; 
        doseMinSum = 42.3714;
        doseMaxSum = 50.7382;
        doseMeanSum = 46.9698;
        volumeDifference = 178.9341;        
        volume48GyDifference = 7.9403;
        dose2PercentDifference = 48.5946; 
        doseMinDifference = 42.3714;
        doseMaxDifference = 49.7521;
        doseMeanDifference = 46.5159;

        relativeError = 0.0035;

        % Required for setup
        wrapperData;
        wrapperDataNoDose;
        
        gtv1;
        gtv1plus2;
        gtv2min1;
    end
    
    methods (TestClassSetup)
        function setupOnce(me)
            ctJava     = mockJavaCtProperties(fullfile(me.BasePath, 'CT'));  
            pathDose   = fullfile(me.BasePath, 'RTDOSE' , me.RTDoseFile);
            pathStruct = fullfile(me.BasePath, 'RTSTRUCT' , me.RTStructFile);
            me.wrapperData = createMatlabDicomObjects(pathStruct, pathDose, ctJava, {'GTV-1', 'GTV-2'});
        end
    end    
    
    methods(Test)
        
		function testGTV1String(me)
            structures = 'GTV-1';
            operators = '';
            
            GTV1 = createCombinedRoiDose(me.wrapperData, structures, operators);
            verifyEqual(me, GTV1.name, 'GTV-1');
        end
        
        function testGTV1NoDoseString(me)
            structures = 'GTV-1';
            operators = '';

            GTV1 = createCombinedRoiDose(me.wrapperData, structures, operators);
            verifyEqual(me, GTV1.name, 'GTV-1');
        end

        function testOperatorsSumStruct(me)
            structures = {'GTV-1', 'GTV-2'};
            operators = '+';

            GTVs = createCombinedRoiDose(me.wrapperData, structures, operators);
            verifyEqual(me, GTVs.name, 'GTV-1+GTV-2');
        end
        
        function testOperatorsDifferenceStruct(me)
            structures = {'GTV-2', 'GTV-1'};
            operators = {'-'};
            
            GTVs = createCombinedRoiDose(me.wrapperData, structures, operators);
            verifyEqual(me, GTVs.name, 'GTV-2-GTV-1');
        end
    end
end