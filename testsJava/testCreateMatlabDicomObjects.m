classdef testCreateMatlabDicomObjects < matlab.unittest.TestCase
    properties
        
        % Locations of test files
        % BasePath should be the path to the folder containing the CT, RTSTRUCT and RTDOSE folders
        BasePath = 'D:\TestData\12345'
        % Filenames should hold the filename of the RTSTRUCT file and RTDOSE file
        RTStructFile = 'FO-4073997332899944647.dcm';
        RTDoseFile   = 'FO-3153671375338877408_v2.dcm';

        NO_STRUCT  = 0;
        ONE_STRUCT = 1;
        TWO_STRUCT = 2;
        
        ctJava = [];
        ct = [];
        pathDose = [];
        pathStruct = [];
    end
    
    methods (TestClassSetup)
        function setupOnce(me)
            me.ctJava = mockJavaCtProperties(fullfile(me.BasePath, 'CT'));
            me.ct = Ct(fullfile(me.BasePath, 'CT'), 'folder', false);
            me.pathDose   = fullfile(me.BasePath, 'RTDOSE' , me.RTDoseFile);
            me.pathStruct = fullfile(me.BasePath, 'RTSTRUCT' , me.RTStructFile);
        end
    end    
    
    methods(Test)
        function testJavaCtProperties(me)
            wrapperData = createMatlabDicomObjects(me.pathStruct, me.pathDose, me.ctJava, {'GTV-1'});
            verifyEqual(me, wrapperData.hasFittedDose, true);
            verifyEqual(me, wrapperData.nrDelineations, me.ONE_STRUCT);
        end
        
        function testCtObject(me)
            wrapperData = createMatlabDicomObjects(me.pathStruct, me.pathDose, me.ct, {'GTV-1'});
            verifyEqual(me, wrapperData.hasFittedDose, true);
            verifyEqual(me, wrapperData.nrDelineations, me.ONE_STRUCT);
        end
        
        function testCtPath(me)
            wrapperData = createMatlabDicomObjects(me.pathStruct, me.pathDose, fullfile(me.BasePath, 'CT'), {'GTV-1'});
            verifyEqual(me, wrapperData.hasFittedDose, true);
            verifyEqual(me, wrapperData.nrDelineations, me.ONE_STRUCT);
        end
        
        function testGetSingleNoDose(me)
            wrapperData = createMatlabDicomObjects(me.pathStruct, '', me.ctJava, {'GTV-1'});
            verifyEqual(me, wrapperData.hasFittedDose, false);
            verifyEqual(me, wrapperData.nrDelineations, me.ONE_STRUCT);
        end
        
		function testGetMultiple(me)
            wrapperData = createMatlabDicomObjects(me.pathStruct, me.pathDose, me.ctJava, {'GTV-1', 'GTV-2'});
            verifyEqual(me, wrapperData.hasFittedDose, true);
            verifyEqual(me, wrapperData.nrDelineations, me.TWO_STRUCT);
        end
        
        function testRoiNotFoundSingle(me)
            wrapperData = createMatlabDicomObjects(me.pathStruct, '', me.ctJava, {'DERP'});
            verifyEqual(me, wrapperData.hasFittedDose, false);
            verifyEqual(me, wrapperData.nrDelineations, me.NO_STRUCT);

        end
        
        function testRoiNotFoundMultiple(me)
            wrapperData = createMatlabDicomObjects(me.pathStruct, '', me.ctJava, {'DERP', 'GTV-1'});
            verifyEqual(me, wrapperData.hasFittedDose, false);
            verifyEqual(me, wrapperData.nrDelineations, me.ONE_STRUCT);
        end
        
        function testErrorNoStruct(me)
            try
                createMatlabDicomObjects('', '', me.ctJava, {'GTV-1'});
            catch EM
                verifyEqual(me, 'matlabData:MissingParamater', EM.identifier);
            end
            
        end
        
        function testErrorNoVolumes(me)
            try
                createMatlabDicomObjects(me.pathStruct, '', me.ctJava, {[]});
            catch EM
                verifyEqual(me, 'matlabData:MissingParamater', EM.identifier);
            end
        end
        
        function testErrorInvalidCtProperties(me)
           errorCtProp = me.ctJava;
           errorCtProp = rmfield(errorCtProp, 'PixelSpacing');
           try
               createMatlabDicomObjects(me.pathStruct, '', errorCtProp, {'GTV-1'});
           catch EM
               verifyEqual(me, 'CtProperties:MissingParamater', EM.identifier);
           end
        end        
    end
end