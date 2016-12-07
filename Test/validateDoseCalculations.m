classdef validateDoseCalculations < matlab.unittest.TestCase

    properties

        % Locations of test files
        BasePath = 'D:\LocalData\TestData\12345';
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
        
        relativeError = 0.0050;

        % Required for setup
        rtStruct;
        rtDose;
        gtv1; 
        gtv2; 
        
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
            gtv1Contour = createContour(struct, 'GTV-1');
            gtv1Voi = createVolumeOfInterest(gtv1Contour, refImage);
            
            gtv2Contour = createContour(struct, 'GTV-2');
            gtv2Voi = createVolumeOfInterest(gtv2Contour, refImage);
            
            this.rtDose = refDose;
            this.gtv1 = gtv1Voi;
            this.gtv2 = gtv2Voi;
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
            
            diffDose = createImageDataForVoi(difference, this.rtDose);
            doseMax = calculateImageStatistics(diffDose, 'max');
            verifyEqual(this, doseMax, this.doseMaxDifference, 'RelTol', this.relativeError);
            
            diffDvh = DoseVolumeHistogram(diffDose, this.BINSIZE);
            
            v48 = calculateDvhV(diffDvh, 48, true);
            verifyEqual(this, v48, this.volume48GyDifference, 'RelTol', this.relativeError);            
            
            d2 = calculateDvhD(diffDvh, 2, true, false);
            verifyEqual(this, d2, this.dose2PercentDifference, 'RelTol', this.relativeError);  
        end
    end
end