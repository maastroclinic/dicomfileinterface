classdef CtScan
    %CTSCAN representation of an entire DICOM CT-SCAN
    %
    %CONSTRUCTORS
    % this = CtScan(pathStr, useVrHeuristics) creates this object using
    %   a folder with CT dicom files + vrHeuristicsBoolean
    %
    % this = CtScan(dicomObjList, useVrHeuristics) creates this object using 
    %   an array of DicomObj ct files + boolean useVrHeuristics
    %
    % this = CtScan(cellOfFiles, useVrHeuristics) creates this object using
    %   a cell array with CT dicom file locations + boolean useVrHeuristics
    %
    % This CT is given in the image coordinate system
    %               -----------         IEC
    %              /|         /|         Z
    %             / |        / |        /|\
    %            /  |       /  |         |   /|\ Y
    %           /   |      /   |         |   /
    %          /    ------/----          |  /
    %          ----/------    /          | /
    %         |   /      |   /           |/
    %         |  /       |  /     X------|----------------->
    %         | /        | /            /|
    %         |/         |/            / |
    %         ------------
    %
    % Origin coordinates will be the bottom-left-corner. The CT cube will
    % be addressed in the following way pixelData(1:columns,1:numberOfSlices,1:rows)
    %
    % See also: DICOMOBJ, CTSLICE, CREATEIMAGEFROMCT
    properties
        ctSlices = CtSlice()
        instanceSortedCtSlices
        ySortedCtSlices
        numberOfSlices
        sliceThickness
        hasUniformThickness
        pixelSpacingX
        pixelSpacingY
        pixelSpacingZ
        originX
        originY
        originZ
        realX
        realY
        realZ
        pixelData
    end
    
    methods
        function this = CtScan(dataInput, useVrHeuristics)
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            
            %if the input is a folder, create file list array
            if ischar(dataInput)
                fileNames = filesUnderFolders(dataInput, 'detail');
                this = this.addListOfFiles(fileNames, useVrHeuristics);
            elseif isa(dataInput, 'DicomObj')
                this = this.addListOfObjects(dataInput);
            elseif iscellstr(dataInput)
                this = this.addListOfFiles(dataInput, useVrHeuristics);
            else
                throw(MException('MATLAB:CtScan:constructor', 'invalid input type, please give a folder location or a file list as a cell array'));
            end
        end
        
        function this = addListOfObjects(this, dicomObj)
            for i = 1:length(dicomObj)
                if ~isa(dicomObj(i), 'CtSlice')
                    ctSlice = CtSlice(dicomObj(i), []);
                else
                    ctSlice = dicomObj(i);
                end
                
                this = this.addCtSlices(ctSlice); 
            end
        end
        
        function this = addListOfFiles(this, files, UseVrHeuristic)
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
        
        function out = get.pixelSpacingY(this)
            out = this.sliceThickness;
        end
        
        function out = get.pixelSpacingX(this)
            slices = this.ySortedCtSlices();
            out = zeros(this.numberOfSlices,1);
            for i = 1:this.numberOfSlices
                out(i) = slices(i).pixelSpacing(1);
            end
            out = unique(out);
        end
        
        function out = get.pixelSpacingZ(this)
            slices = this.ySortedCtSlices();
            out = zeros(this.numberOfSlices,1);
            for i = 1:this.numberOfSlices
                out(i) = slices(i).pixelSpacing(2);
            end
            out = unique(out);
        end
        
        function out = get.originX(this)
            if this.ySortedCtSlices(1).imageOrientationPatient(1) == 1
                out = this.ySortedCtSlices(1).x;
            elseif this.ySortedCtSlices(1).imageOrientationPatient(1) == -1
                out = this.ySortedCtSlices(1).x - ...
                        (this.pixelSpacingX * this.ctSlices(1).columns);
            else
                out = [];
                warning('unsupported ImageOrientationPatient detected, cannot provide origin');
            end
        end
        
        function out = get.originY(this)
            out = this.ySortedCtSlices(1).y; 
        end
        
        function out = get.originZ(this)
            if this.ySortedCtSlices(1).imageOrientationPatient(5) == -1
                out = -this.ySortedCtSlices(1).z;
            elseif this.ySortedCtSlices(1).imageOrientationPatient(5) == 1
                out = -this.ySortedCtSlices(1).z - ...
                        (this.pixelSpacingZ * (this.ySortedCtSlices(1).rows - 1));
            else
                out = [];
                warning('unsupported ImageOrientationPatient detected, cannot provide origin');
            end 
        end
        
        function out = get.realX(this)
            out = (this.originX : this.pixelSpacingX : (this.originX + (this.ctSlices(1).columns - 1) * this.pixelSpacingX))';
        end
        
        function out = get.realY(this)
            out = (this.originY : this.pixelSpacingY : (this.originY + (this.numberOfSlices - 1) * this.pixelSpacingY))';
        end
        
        function out = get.realZ(this)
            out = (this.originZ : this.pixelSpacingZ : (this.originZ + (this.ctSlices(1).rows - 1) * this.pixelSpacingZ))';
        end
        
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
            image = zeros(slices(1).columns, slices(1).rows, this.numberOfSlices);
            %ASSUMPTION MADE -> rows and colums do not change within one scan
            for i = 1:this.numberOfSlices
                image(:,:,i) = slices(i).scaledImageData;
            end
            %convert image to IEC format (see top comment for more info)
            image(:,:,:) = image(end:-1:1,:,:);
            image = permute(image,[ 2 1 3 ]);
            image = permute(image,[ 1 3 2 ]);
        end
    end
end