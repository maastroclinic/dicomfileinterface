classdef testClinicalCase < matlab.unittest.TestCase 
    properties
        BasePath = 'D:\TestData\SDT_UNIT\';
        RTStructFile = '\1.2.840.113654.2.70.1.308235953292173817219853582238430183393';
        RTDoseFile   = '\1.2.840.113654.2.70.1.107138730718371645804484156224118636091';
        
        PTV_VOLUME_REF = 129.5958;
        PTV_DMIN_REF = 0.06600;
        PTV_DMAX_REF = 2.5578;
        PTV_DMEAN_REF = 0.2599;

        LEFT_LUNG_VOLUME_REF = 1851.548195;
        LEFT_LUNG_DMIN_REF = 0.041992842;
        LEFT_LUNG_DMAX_REF = 72.82079128;
        LEFT_LUNG_DMEAN_REF = 9.759395645;
        
        RIGHT_LUNG_VOLUME_REF = 2367.250443;
        RIGHT_LUNG_DMIN_REF = 0.078163786;
        RIGHT_LUNG_DMAX_REF = 23.52122837;
        RIGHT_LUNG_DMEAN_REF = 2.34695252;
               
        LUNGS_MIN_GTV_VOLUME_REF = 4218.798637;
        LUNGS_MIN_GTV_DMIN_REF = 0.041992842;
        LUNGS_MIN_GTV_DMAX_REF = 72.82079128;
        LUNGS_MIN_GTV_DMEAN_REF = 5.600128807;
        
        PTV_D95_REF = 0.0802; %Gy
        PTV_D95_PERC_REF = 0.1336; %Perc
        LUNGS_MIN_GTV_V20_REF = 299.9783 %cc
        LUNGS_MIN_GTV_V20_PERC_REF = 7.110513727 %Perc
        
        TARGET_PRESCRIPTIONDOSE_REF = 60; %Gy, from RTPLAN file
        % these are the original values of the clinical DGRT database.
        % however, after investigating we found that the original
        % interpolation algorithm (which was replaced by the matlab 2015b
        % native interpolation algorithm) somehow excluded the last slice
        % of the PTV delineation from the 3D bitmask, this results in
        % different results, because the rest of the structures validations
        % are correct we assumed that the numbers produced by the software
        % can be used a reference for future testing.
        % PTV_VOLUME_REF = 127.1953583;
        % PTV_DMIN_REF = 0.067815959;
        % PTV_DMAX_REF = 2.557773211;
        % PTV_DMEAN_REF = 0.263388729;
        % PTV_D95_REF = 0.082397365; %Gy
        % PTV_D95_PERC_REF = 0.13733; %Perc

        calcGrid;
        rtDose;
        rtStruct;
        ptv;
        leftLung;
        rightLung;
        gtv;
        
        relativeError = 0.0035;
    end
    
    methods (TestClassSetup)
        function setupOnce(me)
            ct = Ct(fullfile(me.BasePath, 'CT'), 'folder', false);
            me.calcGrid = CalculationGrid(ct, 'ct');               
            me.rtDose   = RtDose(fullfile(me.BasePath, 'RTDOSE', me.RTDoseFile), me.calcGrid);
            me.rtStruct = RtStruct(fullfile(me.BasePath, 'RTSTRUCT', me.RTStructFile), me.calcGrid);
            
            me.ptv = RoiDose('PTVp1', me.calcGrid, me.rtDose, me.rtStruct);
            me.leftLung = RoiDose('Lung L', me.calcGrid, me.rtDose, me.rtStruct);
            me.rightLung = RoiDose('Lung R', me.calcGrid, me.rtDose, me.rtStruct);
            me.gtv = RoiDose('GTVp1', me.calcGrid, me.rtDose, me.rtStruct);
        end
    end
    
    methods(Test)
        function testPTV(me)
            verifyEqual(me, me.ptv.volume, me.PTV_VOLUME_REF, 'RelTol', me.relativeError);
            verifyEqual(me, me.ptv.dose('min'), me.PTV_DMIN_REF, 'RelTol', me.relativeError);
            verifyEqual(me, me.ptv.dose('max'), me.PTV_DMAX_REF, 'RelTol', me.relativeError);
            verifyEqual(me, me.ptv.dose('mean'), me.PTV_DMEAN_REF, 'RelTol', me.relativeError);
            verifyEqual(me, me.ptv.doseToCertainVolume(123.11601), me.PTV_D95_REF, 'RelTol', me.relativeError);
            verifyEqual(me, me.ptv.dosePercentageToCertainVolume(123.11601, me.TARGET_PRESCRIPTIONDOSE_REF), me.PTV_D95_PERC_REF, 'RelTol', me.relativeError);
            verifyEqual(me, me.ptv.doseToCertainVolumePercentage(95), me.PTV_D95_REF, 'RelTol', me.relativeError);
            verifyEqual(me, me.ptv.dosePercentageToCertainVolumePercentage(95, me.TARGET_PRESCRIPTIONDOSE_REF), me.PTV_D95_PERC_REF, 'RelTol', me.relativeError);
        end
        
        function testLeftLung(me)
            verifyEqual(me, me.leftLung.volume, me.LEFT_LUNG_VOLUME_REF, 'RelTol', me.relativeError);
            verifyEqual(me, me.leftLung.dose('min'), me.LEFT_LUNG_DMIN_REF, 'RelTol', me.relativeError);
            verifyEqual(me, me.leftLung.dose('max'), me.LEFT_LUNG_DMAX_REF, 'RelTol', me.relativeError);
            verifyEqual(me, me.leftLung.dose('mean'), me.LEFT_LUNG_DMEAN_REF, 'RelTol', me.relativeError);          
        end
        
        function testRightLung(me)
            verifyEqual(me, me.rightLung.volume, me.RIGHT_LUNG_VOLUME_REF, 'RelTol', me.relativeError);
            verifyEqual(me, me.rightLung.dose('min'), me.RIGHT_LUNG_DMIN_REF, 'RelTol', me.relativeError);
            verifyEqual(me, me.rightLung.dose('max'), me.RIGHT_LUNG_DMAX_REF, 'RelTol', me.relativeError);
            verifyEqual(me, me.rightLung.dose('mean'), me.RIGHT_LUNG_DMEAN_REF, 'RelTol', me.relativeError);          
        end
        
        function testLungsMinGtv(me)
            LungsMinGtv = me.leftLung + me.rightLung - me.gtv;
            verifyEqual(me, LungsMinGtv.volume, me.LUNGS_MIN_GTV_VOLUME_REF, 'RelTol', me.relativeError);
            verifyEqual(me, LungsMinGtv.dose('min'), me.LUNGS_MIN_GTV_DMIN_REF, 'RelTol', me.relativeError);
            verifyEqual(me, LungsMinGtv.dose('max'), me.LUNGS_MIN_GTV_DMAX_REF, 'RelTol', me.relativeError);
            verifyEqual(me, LungsMinGtv.dose('mean'), me.LUNGS_MIN_GTV_DMEAN_REF, 'RelTol', me.relativeError);
            verifyEqual(me, LungsMinGtv.volumeWithDoseOf(20), me.LUNGS_MIN_GTV_V20_REF, 'RelTol', me.relativeError);
            verifyEqual(me, LungsMinGtv.volumePercentageWithDoseOf(20), me.LUNGS_MIN_GTV_V20_PERC_REF, 'RelTol', me.relativeError);
        end
    end
    
end

