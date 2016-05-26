classdef validateDoseCalculations < matlab.unittest.TestCase

    properties

        % Locations of test files
        BasePath = 'D:\TestData\12345';
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
        gtv1; gtv2; 
        mismatchGtv1;
        
        BINSIZE = 0.001;
    end
    
    methods (TestClassSetup)
        function setupOnce(this)
            
            ctScan = CtScan(fullfile(this.BasePath, 'CT'), false);
            struct = RtStruct(fullfile(this.BasePath, 'RTSTRUCT' , this.RTStructFile), true);
            dose = RtDose(fullfile(this.BasePath, 'RTDOSE' , this.RTDoseFile), false);
            
            refImage = createImageFromCt(ctScan, false);
            doseImage = createImageFromRtDose(dose);
            refDose = matchImageRepresentation(doseImage, refImage);
            gtv1 = createContour(struct, 'GTV-1');
            gtv1Voi = createVolumeOfInterest(gtv1, refImage);
            
            gtv2 = createContour(struct, 'GTV-2');
            gtv2Voi = createVolumeOfInterest(gtv2, refImage);
            
            this.rtDose = refDose;
            this.gtv1 = gtv1Voi;
            this.gtv2 = gtv2Voi;
            
%             ct = Ct(fullfile(this.BasePath, 'CT'), 'folder', false);
%             this.calcGrid = CalculationGrid(ct, 'ct');               
%             this.rtDose   = RtDose(fullfile(this.BasePath, 'RTDOSE' , this.RTDoseFile), this.calcGrid.PixelSpacing, this.calcGrid.Origin, this.calcGrid.Axis, this.calcGrid.Dimensions);
%             this.rtStruct = RtStruct(fullfile(this.BasePath, 'RTSTRUCT' , this.RTStructFile), this.calcGrid.PixelSpacing, this.calcGrid.Origin, this.calcGrid.Axis, this.calcGrid.Dimensions);
%             this.Gtv1 = Image('GTV-1', this.rtStruct.getRoiMask('GTV-1'), this.rtDose.fittedDoseCube, this.calcGrid.PixelSpacing, this.calcGrid.Origin, this.calcGrid.Axis, this.calcGrid.Dimensions);
%             this.Gtv2 = Image('GTV-2', this.rtStruct.getRoiMask('GTV-2'), this.rtDose.fittedDoseCube, this.calcGrid.PixelSpacing, this.calcGrid.Origin, this.calcGrid.Axis, this.calcGrid.Dimensions);
            
%             ct = Ct(fullfile(me.BasePath, 'CT_DIMTEST'), 'folder', false);
%             me.mismatchCalcGrid = CalculationGrid(ct, 'ct'); 
%             me.mismatchRtStruct = RtStruct(fullfile(me.BasePath, 'RTSTRUCT' , me.RTStructFile), me.mismatchCalcGrid);
%             me.mismatchRtDose   = RtDose(fullfile(me.BasePath, 'RTDOSE' , me.RTDoseFile), me.mismatchCalcGrid);
%             me.mismatchGtv1 = RtVolume('GTV-1', me.mismatchCalcGrid, me.mismatchRtStruct, me.mismatchRtDose);
        end
    end    
 
    methods(Test)

        
        function testGtv1(this)
            verifyEqual(this, this.gtv1.volume, this.volumeGtv1, 'RelTol', this.relativeError); 
            
            gtvDose = createImageDataForVoi(this.gtv1, this.rtDose);
            dMin = calculateImageStatistics(gtvDose, 'min');
            verifyEqual(this, dMin, this.doseMinGtv1, 'RelTol', this.relativeError);    
            
            dMean = calculateImageStatistics(gtvDose, 'mean');
            verifyEqual(this, dMean, this.doseMeanGtv1, 'RelTol', this.relativeError);
            verifyGreaterThanOrEqual(this, dMean, dMin); 
            
            dMax = calculateImageStatistics(gtvDose, 'max');
            verifyEqual(this, dMax, this.doseMaxGtv1, 'RelTol', this.relativeError);             
            verifyGreaterThanOrEqual(this, dMax, dMean);
            
            gtvDvh = DoseVolumeHistogram(gtvDose, this.BINSIZE);
            
            v48 = calculateDvhV(gtvDvh, 48, true);
            verifyEqual(this, v48, this.volume48GyGtv1, 'RelTol', this.relativeError);            
            
            d2 = calculateDvhD(gtvDvh, 2, true, false);
            verifyEqual(this, d2, this.dose2PercentGtv1, 'RelTol', this.relativeError);
        end

        function testGtv2(this)
            verifyEqual(this, this.gtv2.volume, this.volumeGtv2, 'RelTol', this.relativeError);
            
            gtvDose = createImageDataForVoi(this.gtv2, this.rtDose);
            dMin = calculateImageStatistics(gtvDose, 'min');
            verifyEqual(this, dMin, this.doseMinGtv2, 'RelTol', this.relativeError);
            
            gtvDvh = DoseVolumeHistogram(gtvDose, this.BINSIZE);
            
            v48 = calculateDvhV(gtvDvh, 48, true);
            verifyEqual(this, v48, this.volume48GyGtv2, 'RelTol', this.relativeError);            
            
            d2 = calculateDvhD(gtvDvh, 2, true, false);
            verifyEqual(this, d2, this.dose2PercentGtv2, 'RelTol', this.relativeError); 
        end

        function testOperatorsSum(this)
            sum = this.gtv1 + this.gtv2;            
            
            sumDose = createImageDataForVoi(sum, this.rtDose);
            dMean = calculateImageStatistics(sumDose, 'mean');
            verifyEqual(this, dMean, this.doseMeanSum, 'RelTol', this.relativeError);
            
            sumDvh = DoseVolumeHistogram(sumDose, this.BINSIZE);
            
            v48 = calculateDvhV(sumDvh, 48, true);
            verifyEqual(this, v48, this.volume48GySum, 'RelTol', this.relativeError);            
            
            d2 = calculateDvhD(sumDvh, 2, true, false);
            verifyEqual(this, d2, this.dose2PercentSum, 'RelTol', this.relativeError);  
        end

        function testOperatorsDifference(this)
            sum = this.gtv1 + this.gtv2;
            difference = sum - this.gtv1;
            verifyEqual(this, difference.volume, this.volumeDifference, 'RelTol', this.relativeError);           
            
%             doseMax = difference.dose('max');
%             verifyEqual(me, doseMax, me.doseMaxDifference, 'RelTol', me.relativeError); 
%             verifyEqual(me, me.volume48GyDifference, difference.volumePercentageWithDoseOf(48), 'RelTol', me.relativeError);             
%             verifyEqual(me, me.dose2PercentDifference, difference.doseToCertainVolumePercentage(2), 'RelTol', me.relativeError);
        end
        
%         function testCompressionCloseToCtBoundries(this)
%             body = Image('Body', this.rtStruct.getRoiMask('Body'), this.rtDose.fittedDoseCube, this.calcGrid.PixelSpacing, this.calcGrid.Origin, this.calcGrid.Axis, this.calcGrid.Dimensions);
%             verifyEqual(this, body.volume, this.bodyVolume, 'RelTol', this.relativeError);
%         end
        
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