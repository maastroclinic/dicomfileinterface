classdef RtStruct
    %RTSTRUCT object creates a 3D representation of the 2D delineation
    %information of the RTSTRUCT DICOM object using the CtProperties object
    %to determine the interpolation grid.
    
    properties (SetAccess  = 'private', GetAccess = 'public')
        
        %the variablenames that represent tags do not follow SDT naming conventions 
        % to stay true to the DICOM naming conventions
        DicomHeader;
               
        sliceCollection;
        bitMasks;
        
		rendered;
        nrOfRois;
        
        Origin;
        Dimensions;
        
        % i = lateral direction in image coordinate system
        % j = transversal direction in image coordinate system
        % k = axial direction in image coordinate system
        Axis;
        Axisi; 
        Axisj; 
        Axisk;
        
        PixelSpacing = [0,0,0];
        PixelSpacingi;
        PixelSpacingj;
        PixelSpacingk;

        hasCalcGrid = false;
        
        HasForcedStructures;
        ForcedStructures;
    end
    
    methods
        function this = RtStruct(struct, pixelSpacing, Origin, Axis, Dimensions)
            if nargin > 0
                this = this.setPixelSpacing(pixelSpacing);
                this = this.setOrigin(Origin);
                this = this.setAxis(Axis);
                this = this.setDimensions(Dimensions);
                this = this.parseRTStruct(struct);
            end
        end
        
        function out = isXio(this)
            if strcmpi(this.DicomHeader.ManufacturerModelName,'cms, inc.') || ...
                    strcmpi(this.DicomHeader.ManufacturerModelName,'xio') 
                out = 1;
            else
                out = 0;
            end
        end
        
        function out = isTrueD(this)
            if strfind(lower(this.DicomHeader.StructureSetLabel), 'trued') || ...
                    strfind(lower(this.DicomHeader.SeriesDescription), 'trued') || ...
                    strfind(lower(this.DicomHeader.StructureSetName), 'trued')
                out = 1;
            else
                out = 0;
            end
        end
        
        function out = isEsoft(this)
            if strcmpi(this.DicomHeader.ManufacturerModelName,'Syngo MI Applications') || ...
                    strcmpi(this.DicomHeader.ManufacturerModelName,'e.soft') 
                out = 1;
            else
                out = 0;
            end
        end
        
        function out = isMaastroCon(this)
            if strcmpi(this.DicomHeader.ManufacturerModelName,'MAASTRO clinic') || ...
                    strcmpi(this.DicomHeader.ManufacturerModelName,'MAASTRO_CON')
                out = 1;
            else
                out = 0;
            end
        end

        
        %% old stuff
        
        function out = getRoiMask(this, in)
            
            [index, name] = this.selectRoiNameIndex(in);
            
            if this.rendered{index,2} == 0;
                %suppress the warning on functions genvarname.
                %it is a deprecate function that can be replace once we
                %switch to a newer version of Matlab.
                slices = this.getSlicesForRoi(name);
                if isempty(slices)
                    out = [];
                    return
                end
                rawMask = this.calculateBitmask(slices);
                %bitshift the mask to prevent memory issues
                this.bitMasks = this.bitMasks + uint64(rawMask.*(2^(index-1)));
                this.rendered{index,2} = 1;
            end
            out = double(bitget(this.bitMasks, index));
        end
		
		function image = addRoiToGrayScaleMap(this, image, ctSlice, in)
            ContourMask = this.getRoiMask(in);
            ContourMaskSlice = double(flipud(squeeze(ContourMask(:,ctSlice,:))'));
            ContourList = contourc(double(1:this.Dimensions(1)), double(1:this.Dimensions(3))...
                , ContourMaskSlice, [1.0 1.0]);
            ColorMap = this.getColorMap(in);
            
            limit = size(ContourList,2); i = 1;
            while(i < limit)
                npoints = ContourList(2,i);
                nexti = i+npoints+1;
                Xcontour = ContourList(2,i+1:i+npoints);            % X-coordinate of contour points.
                Ycontour = ContourList(1,i+1:i+npoints);            % Z-coordinate of contour points.
                for j = 1:length(Xcontour)
                    image(Xcontour(j), Ycontour(j), :) = ColorMap;
                end
                i = nexti;
            end
        end
        
        function sliceNrs = findUsedSlices(this, in, first)
            ContourMask = this.getRoiMask(in);
            sliceNrs = [];
            for i = 1:this.Dimensions(2)
                ContourMaskSlice = squeeze(ContourMask(:,i,:));
                if max(max(ContourMaskSlice)) == 1
                    sliceNrs = [sliceNrs, i]; %#ok<AGROW>
                    if first == true
                        return;
                    end
                end
            end
        end
        
        function out = get.PixelSpacingi(this)
            out = this.PixelSpacing(1);
        end
        
        function out = get.PixelSpacingj(this)
            out = this.PixelSpacing(2);
        end
        
        function out = get.PixelSpacingk(this)
            out = this.PixelSpacing(3);
        end
        
        function out = get.Axis(this)
            out.Axisi = this.Axisi;
            out.Axisj = this.Axisj;
            out.Axisk = this.Axisk;
        end 
    end
    
    methods (Access = private)
        function this = setRequiredLabels(this)
            %the code will crash if these tags are missing from the dicom header
            %add empty tags if they are missing from the header
           if ~isfield(this.DicomHeader, 'ManufacturerModelName')
               this.DicomHeader.ManufacturerModelName = '';
           end
           
           if ~isfield(this.DicomHeader, 'StructureSetLabel')
               this.DicomHeader.StructureSetLabel = '';
           end
           
           if ~isfield(this.DicomHeader, 'SeriesDescription')
               this.DicomHeader.SeriesDescription = '';
           end
           
           if ~isfield(this.DicomHeader, 'StructureSetName')
               this.DicomHeader.StructureSetName = '';
           end
           
           if ~isfield(this.DicomHeader, 'ManufacturerModelName')
               this.DicomHeader.ManufacturerModelName = '';
           end
           
        end
        
        function DicomHeader = readDicomFile(~, fileName)
            if ~exist(fileName, 'file')
                structString = regexprep(fileName,'\','\\\');
                throw(MException('Matlab:FileNotFound', ['DICOM RT-STRUCT file ''' structString ''' not found.''']));
            end
            %prevent errors with certain structure sets. The
            %warning is not catch-able so cannot disable only for
            %the problematic structure sets.
            DicomHeader = dicominfo(fileName, 'UseVRHeuristic', false);
        end
        
        function this = parseDicomHeader(this, DicomHeader)
            if isfield(DicomHeader, 'StudyInstanceUID')
                this.DicomHeader = DicomHeader;
            else
                throw(MException('RtStruct:InvalidInput',''));
            end

            this.HasForcedStructures = 0;
            this.ForcedStructures = [];
            for i = 1:length(fieldnames(this.DicomHeader.StructureSetROISequence))
                disp(i);
                contours(i) = ...
                    this.createContourStructure(...
                        this.DicomHeader.StructureSetROISequence, ...
                        this.DicomHeader.RTROIObservationsSequence, ...
                        this.DicomHeader.ROIContourSequence, i); %#ok<AGROW>
            end
            
            for i = 1:length(contours)
                if contours(i).Forced == 1
                    this.HasForcedStructures = 1;
                    if isempty(this.ForcedStructures)
                        this.ForcedStructures = i;
                    else
                        this.ForcedStructures(end+1) = i;
                    end
                end
            end
            
            this.sliceCollection = contours;
            this = this.setRequiredLabels();
            this.nrOfRois = length(this.sliceCollection);
        end
        
        %TODO, got this function from read_dicomrtstruct, it assumes that item_1 is the same object
        %in all the sequences.
        function contour = createContourStructure(~, StructureSetROISequence, RTROIObservationsSequence, ROIContourSequence, i)           
            iItem   =   ['Item_',num2str(i)];
            contour.Name    =   StructureSetROISequence.(iItem).ROIName;  
            contour.Number  =   StructureSetROISequence.(iItem).ROINumber;

            if isfield(StructureSetROISequence.(iItem),'ROIVolume')
                contour.Volume  =   StructureSetROISequence.(iItem).ROIVolume;
            else
                contour.Volume  = 0;
            end
            contour.Forced = 0;
            contour.RelativeElectronDensity = [];
            if isfield(RTROIObservationsSequence.(iItem),'ROIPhysicalPropertiesSequence')
               for i = 1  : length(fields(RTROIObservationsSequence.(iItem).ROIPhysicalPropertiesSequence))
                   contour.Forced = 1;
                   contour.RelativeElectronDensity = RTROIObservationsSequence.(iItem).ROIPhysicalPropertiesSequence.(['Item_' num2str(i)]).ROIPhysicalPropertyValue;               
               end
            end

            if isfield(ROIContourSequence.(iItem), 'ContourSequence')
                if strcmp(ROIContourSequence.(iItem).ContourSequence.Item_1.ContourGeometricType,'CLOSED_PLANAR')
                    contour.ClosedPlanar = 1;
                else
                    contour.ClosedPlanar = 0;
                end

                SliceCur        =   1;
                SliceCurItem    =   'Item_1';
                while isfield(ROIContourSequence.(iItem).ContourSequence,SliceCurItem)
                    contour.Slice(SliceCur).X   =   ROIContourSequence.(iItem).ContourSequence.(SliceCurItem).ContourData(1:3:end)/10;
                    contour.Slice(SliceCur).Y   =   ROIContourSequence.(iItem).ContourSequence.(SliceCurItem).ContourData(3:3:end)/10;
                    contour.Slice(SliceCur).Z   =   -ROIContourSequence.(iItem).ContourSequence.(SliceCurItem).ContourData(2:3:end)/10;
                    SliceCur        =   SliceCur+1;
                    SliceCurItem    =   ['Item_',num2str(SliceCur)];
                end
                contour.SliceNum = SliceCur-1;
            else
                contour.ClosedPlanar = 0;
                contour.SliceNum = [];
                contour.Slice = [];
            end
        end        
        
        function this = setPixelSpacing(this, pixelSpacing)
            this.PixelSpacing = pixelSpacing;
        end
        
        function this = setOrigin(this, Origin)
            this.Origin = Origin;
        end
        
        function this = setDimensions(this, Dimensions)
            this.Dimensions = Dimensions;
            this.bitMasks = zeros(this.Dimensions ,'uint64');
        end

        function this = setAxis(this, Axis)
            this.Axisi = Axis.Axisi;
            this.Axisj = Axis.Axisj;
            this.Axisk = Axis.Axisk;
        end
        
        function this = parseRTStruct(this, struct)
            %check if struct is a read RTSTRUCT or filelocation

            dcm = this.readDicomFile(struct);
            this = this.parseDicomHeader(dcm);
            this = this.parseColorSettingFromHeader(this.DicomHeader);
            this = this.setRenderList();
        end
        
        function this = setRenderList(this)
           for i = 1:length(this.sliceCollection)
               this.rendered{i, 1} = this.sliceCollection(i).Name;
               this.rendered{i, 2} = 0;
           end
        end
		
		function this = setSliceCollection(this, Struct)
            for i = 1:length(Struct)
                index = Struct(i).Number;
                slices(index) = Struct(i); %#ok<AGROW>
            end
            this.sliceCollection = slices;
        end
		
		function this = parseColorSettingFromHeader(this, header)
            for i = 1:length(this.sliceCollection)
                try
                    index = header.ROIContourSequence.(['Item_' num2str(i)]).ReferencedROINumber;
                    color = header.ROIContourSequence.(['Item_' num2str(i)]).ROIDisplayColor./256;
                    this.sliceCollection(index).color = color;
                catch EM
                    warning(['no colormap found, set to default, MATLAB message: ' EM.message]);
                    this.sliceCollection(index).color = 'red';
                end
            end
        end
  
        function out = calculateBitmask(this, Slices)
            %improves readablity of the calculations
            i = this.PixelSpacingi;
            k = this.PixelSpacingk;

            % reshuffle structure data
            Contours = cell(length(Slices),1);
            YPos = zeros(1,length(Slices));
            for n = 1 : length(Slices)
                Contours{n}(:,1) = Slices(n).X; 
                Contours{n}(:,2) = Slices(n).Y; 
                Contours{n}(:,3) = Slices(n).Z;
                YPos(n) = Contours{n}(1,2);
            end

            % determine minimum and maximum structure positions and sizes
            PosMin = min(Contours{1});
            PosMax = max(Contours{1});
            for n = 2 : length(Contours),
                PosMin = min([min(Contours{n}); PosMin]);
                PosMax = max([max(Contours{n}); PosMax]);
            end
            Width  = round((PosMax(1)-PosMin(1))/i)+1;
            Height = round((PosMax(3)-PosMin(3))/k)+1;

            % convert structures to closed area shapes
            [Y,~,J] = unique(YPos);
            structureData = zeros(Width,Height,length(Y));
            for n = 1 : length(Contours),
                structureData(:,:,J(n)) = structureData(:,:,J(n)) + poly2mask( ...
                    (Contours{n}(:,3)-PosMin(3)) / k + 0.5 , ...
                    (Contours{n}(:,1)-PosMin(1)) / i + 0.5, ...
                    Width,Height);
            end
            structureData(structureData > 1) = 1;
            structureData = permute(structureData,[1 3 2]);
            clear Contours;

            % define X/Y/Z vectors of original and new 3D grid
            XStruct = (PosMin(1)+0.5*i:i:PosMin(1)+0.5*i+(Width-1)*i)';
            YStruct = Y';
            ZStruct = (PosMin(3)+0.5*k:k:PosMin(3)+0.5*k+(Height-1)*k)';

            if length(XStruct) > 1 && length(YStruct) > 1 && length(ZStruct) > 1
                % re-sample 3D volume
                out = VolumeResample(structureData,XStruct,YStruct,ZStruct,this.Axisi,this.Axisj,this.Axisk);
                out (out >= 0.5) = 1;
                out (out < 0.5) = 0;
            else
                throw(MException('RtStruct:DelineationData', ['No 3D delineation found, [x, y, z]: ' ...
                    num2str(length(XStruct)) ',' num2str(length(YStruct)) ',' num2str(length(ZStruct))]));
            end
        end
        
        function out = getSlicesForRoi(this, name)
            % Extract the slices for the desired structure
            index = this.getRoiIndexForName(name);
        
            % Although you would expect only one slice base on the
            % property name, it does contain a set of slices. This is
            % caused by the weird naming scheme in read_dicomrtstruct.m
            out = this.sliceCollection(index).Slice;
        end
        
        function index = getRoiIndexForName(this, name)
            index = structfind(this.sliceCollection, 'Name', name);
            if isempty(index)
                throw(MException('RtStruct:UnknownRoiName', ['The requested ROI name(' name ') was not found in the load RTStruct']));
            end
            
            if length(index) > 1
                warning(['the structure name provided is present more than once, '...
                    'selecting the first one found: ' num2str(index(1)) 10 ...
                    'please use the getRoiMask(index) function to get the other structure']);
                index = index(1);
            end
        end
                        
		function out = getColorMap(this, in)
            % Extract the slices for the desired structure
            [index, ~] = this.selectRoiNameIndex(in);
            out = this.sliceCollection(index).color;
            if isempty(out)
                out = [1;1;0];%default red
            end
        end
        
        function [index, name] = selectRoiNameIndex(this, in)
            if ischar(in)
                name = in;
                index = this.getRoiIndexForName(name); 
            elseif length(in)== 1 && isnumeric(in)
                if in <= this.nrOfRois
                    index = in;
                    name = this.sliceCollection(index).Name;
                else
                    throw(MException('RtStruct:InvalidInput', ...
                    ['the index (' num2str(in) ') provided is not present for this RtStruct(' num2str(length(this.nrOfRois)) ')']));
                end
            else
                throw(MException('RtStruct:InvalidInput', ...
                    ['input ' class(in) ' is invalid, please provide a structure index or name']));    
            end
        end
    end    
end

