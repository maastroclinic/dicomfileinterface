classdef testRoiDose < matlab.unittest.TestCase

    properties

        % Locations of test files
        BasePath = 'D:\TestData\12345'
        RTStructFile = '\FO-4073997332899944647.dcm';
        RTDoseFile   = '\FO-3153671375338877408_v2.dcm';
        
        % Results 
        volumeNaN = NaN;
        volumeGtv1 = 57.7583;
        volume48GyGtv1 = 70.5122;
        dose2PercentGtv1 = 49.9198;  
        doseMinGtv1 = 45.4715;
        doseMaxGtv1 = 50.7382;
        doseMeanGtv1 = 48.3759;
        volumeGtv2 = 178.9627;
        volume48GyGtv2 = 7.9438;
        dose2PercentGtv2 = 48.5947; 
        doseMinGtv2 = 42.3714;
        doseMaxGtv2 = 49.7521;
        doseMeanGtv2 = 46.5160;
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
        bodyVolume = 2.0912e+04;
        %there are some unused values in here, leave them for reference
        %purposes
        
        relativeError = 0.0035;

        % Required for setup
        oldPath;
        rtStruct;
        mismatchRtStruct;
        calcGrid;
        mismatchCalcGrid;
        rtDose;
        mismatchRtDose;
        Gtv1; Gtv2; 
        mismatchGtv1;
    end
    
    methods (TestClassSetup)
        function setupOnce(me)
            ct = Ct(fullfile(me.BasePath, 'CT'), 'folder', false);
            me.calcGrid = CalculationGrid(ct, 'ct');               
            me.rtDose   = RtDose(fullfile(me.BasePath, 'RTDOSE' , me.RTDoseFile), me.calcGrid);
            me.rtStruct = RtStruct(fullfile(me.BasePath, 'RTSTRUCT' , me.RTStructFile), me.calcGrid);
            me.Gtv1 = RtVolume('GTV-1', me.calcGrid, me.rtStruct, me.rtDose);
            me.Gtv2 = RtVolume('GTV-2', me.calcGrid, me.rtStruct, me.rtDose);
            
            ct = Ct(fullfile(me.BasePath, 'CT_DIMTEST'), 'folder', false);
            me.mismatchCalcGrid = CalculationGrid(ct, 'ct'); 
            me.mismatchRtStruct = RtStruct(fullfile(me.BasePath, 'RTSTRUCT' , me.RTStructFile), me.mismatchCalcGrid);
            me.mismatchRtDose   = RtDose(fullfile(me.BasePath, 'RTDOSE' , me.RTDoseFile), me.mismatchCalcGrid);
            me.mismatchGtv1 = RtVolume('GTV-1', me.mismatchCalcGrid, me.mismatchRtStruct, me.mismatchRtDose);
        end
    end    
 
    methods(Test)
%         function testParseDoseSeperately(me)
%             Gtv = RoiDose('GTV-1', me.calcGrid, me.rtStruct);
%             Gtv = Gtv.addRtDose(me.rtDose);
%             verifyEqual(me, me.Gtv1.dose('min'), Gtv.dose('min'), 'RelTol', me.relativeError);
%             verifyEqual(me, me.volume48GyGtv1, Gtv.volumePercentageWithDoseOf(48), 'RelTol', me.relativeError);            
%             verifyEqual(me, me.dose2PercentGtv1, Gtv.doseToCertainVolumePercentage(2), 'RelTol', me.relativeError); 
%         end
        
%         function testCtVolumeGtv1(me)
%             ct = Ct(fullfile(me.BasePath, 'CT'), 'folder', true);
%             GtvCt = RoiDose('GTV-1', me.calcGrid, me.rtStruct, ct);
%             verifyEqual(me, double(~isnan(GtvCt.bitmaskCt)), GtvCt.bitmask);
%         end
%         
        function testGtv1(me)
            verifyEqual(me, me.Gtv1.name, 'GTV-1'); 
            verifyEqual(me, me.Gtv1.volume, me.volumeGtv1, 'RelTol', me.relativeError); 
            
            dMin = minMeanMaxImage(me.Gtv1.roiValues, 'min');
            verifyEqual(me, dMin, me.doseMinGtv1, 'RelTol', me.relativeError);    
            
            dMean = minMeanMaxImage(me.Gtv1.roiValues, 'mean');
            verifyEqual(me, dMean, me.doseMeanGtv1, 'RelTol', me.relativeError);
            verifyGreaterThanOrEqual(me, dMean, dMin); 
            
            dMax = minMeanMaxImage(me.Gtv1.roiValues, 'max');
            verifyEqual(me, dMax, me.doseMaxGtv1, 'RelTol', me.relativeError);             
            verifyGreaterThanOrEqual(me, dMax, dMean);
            
            v48 = volumeWithDoseOf(me.Gtv1.roiValues, me.Gtv1.calcGrid.PixelSpacing, 48, true, me.Gtv1.volume);
            verifyEqual(me, v48, me.volume48GyGtv1, 'RelTol', me.relativeError);            
            
            d2 = doseToCertainVolume(me.Gtv1.roiValues, me.Gtv1.calcGrid.PixelSpacing, 2, true, me.Gtv1.volume, false, []);
            verifyEqual(me, d2, me.dose2PercentGtv1, 'RelTol', me.relativeError);
            
            
        end

%         function testGtv2(me)
%             verifyEqual(me, me.Gtv2.name, 'GTV-2'); 
%             verifyEqual(me, me.Gtv2.volume, me.volumeGtv2, 'RelTol', me.relativeError);
%             verifyEqual(me, me.Gtv2.dose('min'), me.doseMinGtv2, 'RelTol', me.relativeError);
%             verifyEqual(me, me.volume48GyGtv2, me.Gtv2.volumePercentageWithDoseOf(48), 'RelTol', me.relativeError); 
%             verifyEqual(me, me.dose2PercentGtv2, me.Gtv2.doseToCertainVolumePercentage(2), 'RelTol', me.relativeError); 
%         end
% 
%         function testOperatorsSum(me)
%             sum = me.Gtv1 + me.Gtv2;            
%             verifyEqual(me, sum.name, 'GTV-1+GTV-2'); 
%             doseMean = sum.dose('mean');
%             verifyEqual(me, doseMean, me.doseMeanSum, 'RelTol', me.relativeError);
%             verifyEqual(me, me.volume48GySum, sum.volumePercentageWithDoseOf(48), 'RelTol', me.relativeError);            
%             verifyEqual(me, me.dose2PercentSum, sum.doseToCertainVolumePercentage(2), 'RelTol', me.relativeError); 
%         end
% 
%         function testOperatorsDifference(me)
%             sum = me.Gtv1 + me.Gtv2;
%             difference = sum - me.Gtv1;
%             verifyEqual(me, difference.name, 'GTV-1+GTV-2-GTV-1'); 
%             verifyEqual(me, difference.volume, me.volumeDifference, 'RelTol', me.relativeError);           
%             doseMax = difference.dose('max');
%             verifyEqual(me, doseMax, me.doseMaxDifference, 'RelTol', me.relativeError); 
%             verifyEqual(me, me.volume48GyDifference, difference.volumePercentageWithDoseOf(48), 'RelTol', me.relativeError);             
%             verifyEqual(me, me.dose2PercentDifference, difference.doseToCertainVolumePercentage(2), 'RelTol', me.relativeError);
%         end
%         
%         function testCompressionCloseToCtBoundries(me)
%             body = RoiDose('Body', me.calcGrid, me.rtStruct);
%             verifyEqual(me, body.volume, me.bodyVolume, 'RelTol', me.relativeError);
%         end
%         
%         function testDoseOverwrite(me)
%             try
%                 me.Gtv1.addRtDose(me.rtDose);
%             catch EM
%                 verifyEqual(me, 'RtVolume:rtDoseOverwrite', EM.identifier);
%             end
%             
%         end
%         
%         function testDoseMismatch(me)
%             try
%                 Gtv = RoiDose('GTV-1', me.calcGrid, me.rtStruct);
%                 Gtv.addRtDose(me.mismatchRtDose);
%             catch EM
%                 verifyEqual(me, 'RtVolume:DimensionMismatch', EM.identifier);
%             end
%         end
%         
%         function testPlusMismatch(me)
%             try
%                 sum = me.Gtv1 + me.mismatchGtv1; %#ok<NASGU>
%             catch EM
%                 verifyEqual(me, 'AbstractVolume:PlusDimensionMismatch', EM.identifier);
%             end
%         end
%         
%         function testMinusMismatch(me)
%             try
%                 diff = me.Gtv1 - me.mismatchGtv1; %#ok<NASGU>
%             catch EM
%                 verifyEqual(me, 'AbstractVolume:MinusDimensionMismatch', EM.identifier);
%             end
%         end
    end
end