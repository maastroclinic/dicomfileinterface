classdef Ct
    %CT is the object representation of the DICOM CT scan
    %Constructors:
    %Ct(DicomHeader, readImageData) 
    % ** use read_dicomct function to create the header
    %Ct(CtFolderScanString, readImageData)
    % ** example 'D:\TestData\12345\'
    
    properties (SetAccess  = 'private', GetAccess = 'public')       
        PixelSpacing = [];
        SliceThickness = [];
        Rows = [];
        Columns = [];
        ImageOrientationPatient =  [];
        ImagePositionPatient =  [];
        CTFileLength = [];
        
        imageData;
        hasImageData = false;
        colorMap;
        mapLower = 0;
        mapUpper = 2000;
        HU_OFFSET = 1024;
    end
    
    methods
        function me = Ct(in, type, readImageData)
            try
                type = lower(type);
                switch type
                    case 'folder'
                        me = me.parseFolderLocation(in, readImageData);
                    case 'dicomheader'
                        me = me.parseCt(in, readImageData);
                    case 'files'
                        me = me.parseFileList(in, readImageData);
                    otherwise
                        throw(MException('Ct:InvalidInput', ...
                            'Please consult the documentation for valid inputs'));
                end
            catch EM
                throw(MException('Ct:InvalidInput', ...
                            'Please consult the documentation for valid inputs'));
            end
        end
                
        function grayscaleImage = createGreyScaleMap(me, sliceNr)
            image = (squeeze(me.imageData(:,sliceNr,:)))';
            grayscaleImage = zeros(me.Rows, me.Columns, 3);
            for i = 1:me.Rows
                for j = 1:me.Columns 
                    index = image(i,j)+1;
                    if index < me.mapLower+1;
                        index = me.mapLower+1;
                    elseif index > me.mapUpper+1
                        index = me.mapUpper+1; 
                    end
                    grayscaleImage(i,j,:) = me.colorMap(index - me.mapLower); 
                end
            end
            grayscaleImage = flipud(grayscaleImage);
        end
        
        function me = setCustomColorMap(me, colorMap)
            if isnumeric(colorMap) && size(colorMap, 2) == 3
                me.colorMap = colorMap;
            else
                throw(MException('Ct:InvalidInput', ...
                    'The selected colormap is not valid, please insert a [:,3]double'));
            end
        end
        
        function me = setWindowLevelGrayScale(me, lower, upper)
            me.mapLower = lower;
            me.mapUpper = upper;
            grayScale = gray(upper);
            me.colorMap = grayScale(lower+1:end, :);
        end
    end
    
    methods (Access  = private)
        %this only works if the foldor contains only CT dicom files.
         function  me = parseFolderLocation(me, folderLocation, readImageData)
             fileNames = dir(folderLocation);
             fileNames = fileNames(~ismember({fileNames.name},{'.','..'}));
            
             ctFileNames = cell(0,0);
             for i = 1:length(fileNames)
                 fileName =fullfile(folderLocation, fileNames(i).name);
                 if me.isDicomFile(fileName)
                     index = length(ctFileNames)+1;
                     ctFileNames{index} = fileName;
                 end
             end

             ctScan = read_dicomct(ctFileNames);
             me = me.parseCt(ctScan, readImageData);
         end
         
         function me = parseFileList(me, ctFileNames, readImageData)
             for i = 1:length(ctFileNames)
                 if ~exist(ctFileNames{i}, 'file')
                     throw(MException('Ct:InvalidInput', ...
                        'One of the provided CT files does not exist'));
                 end
             end
             
             ctScan = read_dicomct(ctFileNames);
             me = me.parseCt(ctScan, readImageData);
         end
        
         function me = parseCt(me, ctScan, readImageData)
            me.PixelSpacing = ctScan.DicomHeader.PixelSpacing;
            me.SliceThickness = ctScan.DicomHeader.SliceThickness;
            me.Rows = ctScan.DicomHeader.Rows;
            me.Columns = ctScan.DicomHeader.Columns;
            me.ImageOrientationPatient = ctScan.DicomHeader.ImageOrientationPatient;
            me.ImagePositionPatient = ctScan.DicomHeader.ImagePositionPatient;
            me.CTFileLength = length(ctScan.Filenames);
                        
           	me.colorMap = gray(me.mapUpper);
            
            if readImageData
                me.imageData = ctScan.Image + me.HU_OFFSET;
                me.hasImageData = true;
            end
         end
        
         function out = isDicomFile(~,fileName)
             out = false;
             
             try
                 pFile = fopen(fileName, 'r');
                 fileHeader = fread(pFile, 132, 'char');
             catch EM
                 warning(['could not determine DICOM signature in file' 10 EM.message]);
             end
             
             try
                 fclose(pFile);
             catch
             end;
             
             dcmSignature = char(fileHeader(end-3:end))';
             if strcmp('DICM', dcmSignature)
                 out = true;
             end
         end
    end
end