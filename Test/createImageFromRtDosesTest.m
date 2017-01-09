classdef createImageFromRtDosesTest < matlab.unittest.TestCase

    properties

        % Locations of test files
        BasePath = 'C:/Testdata/P0076C0057I1896468';
        patientId = 'P0076C0057I1896468';
        planId = '1p1b2d1a';
        planId2 = '1p1b2d2a';
        
        relativeError = 0.0050;
        
        BINSIZE = 0.001;
        
        struct;
        rtDoses = RtDose();
        refImage;
        doseNotTheSame;
    end
    
    methods (TestClassSetup)
        function setupOnce(this)
            addpath(genpath('.\HierarchyStructure'));
            addpath(genpath('.\ModalityStructure'));

            myDicomFiles = DicomDatabase(this.BasePath);
            [~, dose1, ~, ctScan] = createPlanPackage(myDicomFiles.getPatientObject(...
                                                        this.patientId), this.planId);
            [~, dose2, this.struct, ~] = createPlanPackage(myDicomFiles.getPatientObject(...
                                                        this.patientId), this.planId2);
            
            this.doseNotTheSame = dose1;
            this.doseNotTheSame.dicomHeader.FrameOfReferenceUID = dicomuid;
            this.refImage = createImageFromCt(ctScan, false);

            this.rtDoses(1) = dose1;
            this.rtDoses(2) = dose2;
        end
    end    
 
    methods(Test)
        function testDvh(this)
            combinedRtDose = createImageFromRtDoses(this.rtDoses, this.refImage);
            ptv1 = createContour(this.struct, 'PTV-1');
            ptvVoi = createVolumeOfInterest(ptv1, this.refImage);
            ptvDose = createImageDataForVoi(ptvVoi, combinedRtDose);
            ptvDvh = DoseVolumeHistogram(ptvDose, 0.1);
            verifyEqual(this, ptvDvh.maxDose, 77.3669, 'RelTol', this.relativeError);
        end
        
        function testDoseNotTheSame(this)
            combinedRtDose = createImageFromRtDoses([this.rtDoses, this.doseNotTheSame], this.refImage);
            verifyEqual(this, isempty(combinedRtDose.pixelData), true, 'RelTol', this.relativeError);
        end
    end
end