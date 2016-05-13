classdef CtScan < DicomObj
    %CTSCAN representation of an entire DICOM CT-SCAN
    
    properties
        ctSlices = CtSlice();
        instanceSortedCtSlices;
        ySortedCtSlices;
        numberOfSlices;
        sliceThickness;
        hasUniformThickness;
        pixelSpacing;
        hasUniformPixelSpacing;
    end
    
    methods
        function this = CtScan(varargin)
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            
            %if the input is a folder, create file list array
            if ischar(varargin{1})
                fileNames = scanFolder(varargin{1}, varargin{3});
                this = this.addListOfFiles(fileNames, varargin{2});
            elseif isa(varargin{1}, 'DicomObj')
                this = this.addListOfObjects(varargin{1});
            elseif isa(varargin{1}, 'cell')
                list = varargin{1};
                if ischar(list{1}) && exist(list{1}, 'file')
                    this = this.addListOfFiles(list, varargin{3});
                else
                    throw(MException('MATLAB:CtScan:constructor', 'invalid input, the first file in the file list does not exist'));
                end
            else
                throw(MException('MATLAB:CtScan:constructor', 'invalid input type, please give a folder location or a file list as a cell array'));
            end
        end
        
        function this = addListOfObjects(this, dicomObj)
            this = constructorParser(this, 'ct', dicomObj);
            for i = 1:length(dicomObj)
                this.ctSlices(dicomObj(i)); 
            end
        end
        
        function this = addListOfFiles(this, files, UseVrHeuristic)
            this = constructorParser(this, 'ct', files{1}, UseVrHeuristic);
            for i = 1:length(files)
                ctSlice = CtSlice(files{i}, UseVrHeuristic);
                this = this.addCtSlices(ctSlice); 
            end
        end
        
        function this = addCtSlices(this, ctSlice)
            if isempty(this.ctSlices(1).dicomHeader)
                this.ctSlices(1) = ctSlice;
            else
                index = length(this.ctSlices) + 1;
                this.ctSlices(index) = ctSlice;
            end
        end
   
        function out = get.ctSlices(this)
            if ~isempty(this.ctSlices(1).dicomHeader)
                out = this.ctSlices;
            else
                out = CtSlice();
            end
        end
        
        function out = get.instanceSortedCtSlices(this)
            out = orderStructureArray(this.ctSlices, 'instanceNumber');
        end
        
        function out = get.ySortedCtSlices(this)
            out = orderStructureArray(this.ctSlices, 'y');
        end
        
        function out = get.numberOfSlices(this)
            out = length(this.ctSlices);
        end   
        
        function out = get.hasUniformThickness(this)
            out = false;
            if length(this.sliceThickness) == 1
                out = true;
            end
        end
        
        function out = get.sliceThickness(this)
            slices = this.ySortedCtSlices();
            out = zeros(1, this.numberOfSlices);
            for i = 1:this.numberOfSlices
                out(i) = slices(i).sliceThickness;
            end
            out = unique(out);
        end
        
        function out = get.hasUniformPixelSpacing(this)
            out = false;
            if length(this.pixelSpacing) == 2
                out = true;
            end
        end
        
        function out = get.pixelSpacing(this)
            slices = this.ySortedCtSlices();
            out = zeros(this.numberOfSlices,2);
            for i = 1:this.numberOfSlices
                out(i,1) = slices(i).pixelSpacing(1);
                out(i,2) = slices(i).pixelSpacing(2);
            end
            out = unique(out, 'rows');
        end
        
        %OVERWRITE read function to read the entire scan
        function this = readDicomData(this)
            if ~isempty(this.pixelData)
                warning('pixel data already loaded, skipping ctScan.readDicomData');
                return;
            end
           
            for i = 1:this.numberOfSlices
                this.ctSlices(i) = this.ctSlices(i).readDicomData();
            end
            
            this.pixelData = this.createIecImage();
        end
        
    end
    
    methods (Access = 'private')
        function image = createIecImage(this)
            slices = this.ySortedCtSlices;
            image = zeros(slices(1).rows, slices(1).columns, this.numberOfSlices);
            %ASSUMPTION MADE -> rows and colums do not change within one scan
            for i = 1:this.numberOfSlices
                image(:,:,i) = slices(i).scaledImageData;
            end
                        
            %convert image to IEC format
            %copied this VOODOO from DGRT code, should try to understand this one day...
            image(:,:,:) = image(end:-1:1,:,:);
            image = permute(image,[ 2 1 3 ]);
            image = permute(image,[ 1 3 2 ]);
        end
    end
end