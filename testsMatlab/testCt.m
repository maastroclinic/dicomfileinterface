classdef testCt < matlab.unittest.TestCase
    
    properties
        % Locations of test files
        % BasePath should be the path to the folder containing the CT, RTSTRUCT and RTDOSE folders
        BasePath = 'D:\TestData\12345'
        %path to refAxis mat file
        refAxisPath = 'refAxis.mat';
        
        PERCISION = 0.0001;
        READ_IMAGE_DATA = true;
        NO_IMAGE_DATA = false;
        
        CONSTRUCTOR_FOLDER = 'folder';
        CONSTRUCTOR_FILES  = 'files';
        CONSTRUCTOR_HEADER = 'dicomheader';
        CONSTRUCTOR_ERROR  = 'error';
        
        REF_PIXELSPACING = [0.9766 0.9766]';
        REF_SLICETICKNESS = 3;
        REF_ROWS = uint16(512);
        REF_COLUMS = uint16(512);
        REF_IMAGEORIENTATIONPATIENT = [1 0 0 0 1 0]';
        REF_IMAGEPOSITIONPATIENT = [-249.5117 -415.5117 -685.5000]';
        REF_CTFILELENGTH = 136;
    end  
    
    methods(Test)

        function testConstructorFolder(me)
            ct = Ct(fullfile(me.BasePath, 'CT'), me.CONSTRUCTOR_FOLDER, me.READ_IMAGE_DATA);
            verifyEqual(me, ct.PixelSpacing, me.REF_PIXELSPACING, 'AbsTol', me.PERCISION);
            verifyEqual(me, ct.SliceThickness, me.REF_SLICETICKNESS, 'AbsTol', me.PERCISION);
            verifyEqual(me, ct.Rows, me.REF_ROWS, 'AbsTol', me.PERCISION);
            verifyEqual(me, ct.Columns, me.REF_COLUMS, 'AbsTol', me.PERCISION);
            verifyEqual(me, ct.ImageOrientationPatient, me.REF_IMAGEORIENTATIONPATIENT, 'AbsTol', me.PERCISION);
            verifyEqual(me, ct.ImagePositionPatient, me.REF_IMAGEPOSITIONPATIENT, 'AbsTol', me.PERCISION);
            verifyEqual(me, ct.CTFileLength, me.REF_CTFILELENGTH, 'AbsTol', me.PERCISION);
        end
        
        function testConstructorHeaders(me)
            fileNames = dir(fullfile(me.BasePath, 'CT'));
            fileNames = fileNames(~ismember({fileNames.name},{'.','..'}));
            for i = 1:length(fileNames)
                ctFiles{i} = fullfile(me.BasePath, 'CT', fileNames(i).name); %#ok<AGROW>
            end
            ctScan = read_dicomct(ctFiles);
            ct = Ct(ctScan, me.CONSTRUCTOR_HEADER, me.NO_IMAGE_DATA);
            verifyEqual(me, ct.PixelSpacing, me.REF_PIXELSPACING, 'AbsTol', me.PERCISION);
            verifyEqual(me, ct.SliceThickness, me.REF_SLICETICKNESS, 'AbsTol', me.PERCISION);
            verifyEqual(me, ct.Rows, me.REF_ROWS, 'AbsTol', me.PERCISION);
            verifyEqual(me, ct.Columns, me.REF_COLUMS, 'AbsTol', me.PERCISION);
            verifyEqual(me, ct.ImageOrientationPatient, me.REF_IMAGEORIENTATIONPATIENT, 'AbsTol', me.PERCISION);
            verifyEqual(me, ct.ImagePositionPatient, me.REF_IMAGEPOSITIONPATIENT, 'AbsTol', me.PERCISION);
            verifyEqual(me, ct.CTFileLength, me.REF_CTFILELENGTH, 'AbsTol', me.PERCISION);
        end
        
        function testConstructorFiles(me)
            fileNames = dir(fullfile(me.BasePath, 'CT'));
            fileNames = fileNames(~ismember({fileNames.name},{'.','..'}));
            for i = 1:length(fileNames)
                ctFiles{i} = fullfile(me.BasePath, 'CT', fileNames(i).name); %#ok<AGROW>
            end
            ct = Ct(ctFiles, me.CONSTRUCTOR_FILES, me.NO_IMAGE_DATA);
            verifyEqual(me, ct.PixelSpacing, me.REF_PIXELSPACING, 'AbsTol', me.PERCISION);
            verifyEqual(me, ct.SliceThickness, me.REF_SLICETICKNESS, 'AbsTol', me.PERCISION);
            verifyEqual(me, ct.Rows, me.REF_ROWS, 'AbsTol', me.PERCISION);
            verifyEqual(me, ct.Columns, me.REF_COLUMS, 'AbsTol', me.PERCISION);
            verifyEqual(me, ct.ImageOrientationPatient, me.REF_IMAGEORIENTATIONPATIENT, 'AbsTol', me.PERCISION);
            verifyEqual(me, ct.ImagePositionPatient, me.REF_IMAGEPOSITIONPATIENT, 'AbsTol', me.PERCISION);
            verifyEqual(me, ct.CTFileLength, me.REF_CTFILELENGTH, 'AbsTol', me.PERCISION);
        end
        
        function testConstructorWrongInput(me)
            try 
                Ct([], me.CONSTRUCTOR_ERROR, []);
            catch EM
                verifyEqual(me, EM.identifier, 'Ct:InvalidInput');
            end
        end
             
    end
    
end

