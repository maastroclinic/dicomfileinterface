classdef testAllCalculationWrappers < matlab.unittest.TestCase
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
        V_LIMIT = 48;
        D_LIMIT = 2;
        D_LIMIT_ABS = 0;
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
            
            me.gtv1 = createCombinedRoiDose(me.wrapperData, {'GTV-1'}, []);
            me.gtv1plus2 = createCombinedRoiDose(me.wrapperData, {'GTV-1', 'GTV-2'}, {'+'});
            me.gtv2min1 = createCombinedRoiDose(me.wrapperData, {'GTV-2', 'GTV-1'}, {'-'});
        end
    end    
    
    methods(Test)
        
		function testCalculateVolume(me)
            verifyEqual(me, calculateVolume(me.gtv1), me.volumeGTV1, 'RelTol', me.relativeError);
            verifyEqual(me, calculateVolume(me.gtv1plus2), me.volumeSum, 'RelTol', me.relativeError);
            verifyEqual(me, calculateVolume(me.gtv2min1), me.volumeDifference, 'RelTol', me.relativeError);
        end
        
        function testCalculateDose(me)
            verifyEqual(me, calculateDose(me.gtv1, 'min'), me.doseMinGTV1, 'RelTol', me.relativeError);
            verifyEqual(me, calculateDose(me.gtv1plus2, 'min'), me.doseMinSum, 'RelTol', me.relativeError);
            verifyEqual(me, calculateDose(me.gtv2min1, 'min'), me.doseMinDifference, 'RelTol', me.relativeError);
            
            verifyEqual(me, calculateDose(me.gtv1, 'mean'), me.doseMeanGTV1, 'RelTol', me.relativeError);
            verifyEqual(me, calculateDose(me.gtv1plus2, 'mean'), me.doseMeanSum, 'RelTol', me.relativeError);
            verifyEqual(me, calculateDose(me.gtv2min1, 'mean'), me.doseMeanDifference, 'RelTol', me.relativeError);
            
            verifyEqual(me, calculateDose(me.gtv1, 'max'), me.doseMaxGTV1, 'RelTol', me.relativeError);
            verifyEqual(me, calculateDose(me.gtv1plus2, 'max'), me.doseMaxSum, 'RelTol', me.relativeError);
            verifyEqual(me, calculateDose(me.gtv2min1, 'max'), me.doseMaxDifference, 'RelTol', me.relativeError);
        end
        
        function testCalculateDvhV(me)
            verifyEqual(me, calculateDvhV(me.gtv1, me.V_LIMIT, false), me.volume48GyGTV1, 'RelTol', me.relativeError);
            verifyEqual(me, calculateDvhV(me.gtv1plus2, me.V_LIMIT, false), me.volume48GySum, 'RelTol', me.relativeError);
            verifyEqual(me, calculateDvhV(me.gtv2min1, me.V_LIMIT, false), me.volume48GyDifference, 'RelTol', me.relativeError);
        end
        
        function testCalculateDvhD(me)
            verifyEqual(me, calculateDvhD(me.gtv1, me.D_LIMIT, '%', [], true), me.dose2PercentGTV1, 'RelTol', me.relativeError);
            verifyEqual(me, calculateDvhD(me.gtv1plus2, me.D_LIMIT, '%', [], true), me.dose2PercentSum, 'RelTol', me.relativeError);
            verifyEqual(me, calculateDvhD(me.gtv2min1, me.D_LIMIT, '%', [], true), me.dose2PercentDifference, 'RelTol', me.relativeError);
        end
        
        function testDvhCurve(me)
            [vVolume, vDose] = calculateDvhCurve(me.gtv1, me.DVH_BINSIZE, false);
            ref = load(fullfile(me.BasePath, me.REF_DVH));
            
            %TODO, this test should be better, but because a total test
            %patient recode is planned i will save time now
            verifyEqual(me, vVolume, ref.out{1}.volumeVector, 'RelTol', me.relativeError);
            verifyEqual(me, vDose, ref.out{1}.doseVector, 'RelTol', me.relativeError);
        end
        
        function testObjectExport(me)
            path = createMatlabSerializedRoiObj(me.gtv1,[]);
            obj = load(path);
            Gtv = obj.roiObj;
            
            verifyEqual(me, calculateVolume(Gtv), me.volumeGTV1, 'RelTol', me.relativeError);
            verifyEqual(me, calculateDose(Gtv, 'min'), me.doseMinGTV1, 'RelTol', me.relativeError);
            delete(path);
        end
    end
end