classdef testRtStruct < matlab.unittest.TestCase
    
        properties
        % BasePath should be the path to the folder containing the CT, RTSTRUCT and RTDOSE folders
        BasePath = 'D:\TestData\12345'
        %path and name of the logfile for log4m
        loggerPath = '';
        %path to refAxis mat file
        refAxisPath = 'refAxis.mat';
        refGtv1Path = 'refGtv1Mask.mat';
        refGtv2Path = 'refGtv2Mask.mat';
        
        % Filenames should hold the filename of the RTSTRUCT file and RTDOSE file
        RTStructFile = 'FO-4073997332899944647.dcm';
      
        PERCISION = 0.0001;
        oldPath; 
        calcGrid;
        rtStruct;
        rtStructDicom;
        
        % verification values
        REF_GTV1;
        REF_GTV2;
        REF_AXIS; 
    end
    
    methods (TestClassSetup)
        function setupOnce(me)
            ct = Ct(fullfile(me.BasePath, 'CT'), 'folder', false);
            me.calcGrid = CalculationGrid(ct, 'ct');       
            me.rtStructDicom = read_dicomrtstruct(fullfile(me.BasePath, 'RTSTRUCT' , me.RTStructFile));
            me.rtStruct = RtStruct(me.rtStructDicom, me.calcGrid.PixelSpacing, me.calcGrid.Origin, me.calcGrid.Axis, me.calcGrid.Dimensions);

            load(fullfile(me.BasePath, me.refAxisPath));
            me.REF_AXIS = refAxis;
            
            load(fullfile(me.BasePath, me.refGtv1Path));
            me.REF_GTV1 = refGtv1Mask;
            
            load(fullfile(me.BasePath, me.refGtv2Path));
            me.REF_GTV2 = refGtv2Mask;
        end
    end    

    methods(Test)
        function testOneStructure(me)
            mask = me.rtStruct.getRoiMask('GTV-1');           
            verifyEqual(me, mask, me.REF_GTV1, 'AbsTol', me.PERCISION);
        end
        
        function testOneStructureIndex(me)
            mask = me.rtStruct.getRoiMask(7); %index 7 is GTV-1      
            verifyEqual(me, mask, me.REF_GTV1, 'AbsTol', me.PERCISION);
        end
        
        function testMultipleStructures(me)
            mask = me.rtStruct.getRoiMask('GTV-1');           
            verifyEqual(me, mask, me.REF_GTV1, 'AbsTol', me.PERCISION);
            
            mask = me.rtStruct.getRoiMask('GTV-2');           
            verifyEqual(me, mask, me.REF_GTV2, 'AbsTol', me.PERCISION);
        end
        
        function testReadFileConstructor(me)
            rtStructFileread = RtStruct(fullfile(me.BasePath, 'RTSTRUCT' , me.RTStructFile), me.calcGrid.PixelSpacing, me.calcGrid.Origin, me.calcGrid.Axis, me.calcGrid.Dimensions);
            rtStructFileread.getRoiMask('GTV-1');
            rtStructFileread.getRoiMask('GTV-2');
            verifyEqual(me, rtStructFileread, me.rtStruct);
        end
        
        
        function testRtstructFileNotFound(me)
            try
                RtStruct(fullfile(me.BasePath, 'ERROR' , me.RTStructFile), me.calcGrid.PixelSpacing, me.calcGrid.Origin, me.calcGrid.Axis, me.calcGrid.Dimensions);
            catch EM
                verifyEqual(me, 'Matlab:FileNotFound', EM.identifier);
            end
        end
        
        function testRoiNotFound(me)
            try
                me.rtStruct.getRoiMask('unknown');
            catch EM
                verifyEqual(me, 'RtStruct:UnknownRoiName', EM.identifier);
            end
        end
        
        function testIndexNotFound(me)
            try
                me.rtStruct.getRoiMask(50);
            catch EM
                verifyEqual(me, 'RtStruct:InvalidInput', EM.identifier);
            end
        end
        
        function testInvalidInputForMaskFuntion(me)
            try
                me.rtStruct.getRoiMask({1});
            catch EM
                verifyEqual(me, 'RtStruct:InvalidInput', EM.identifier);
            end
            
            try
                me.rtStruct.getRoiMask([1,1]);
            catch EM
                verifyEqual(me, 'RtStruct:InvalidInput', EM.identifier);
            end
        end
    end
end