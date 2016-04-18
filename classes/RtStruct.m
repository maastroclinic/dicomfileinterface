classdef RtStruct
    %RTSTRUCT object creates a 3D representation of the 2D delineation
    %information of the RTSTRUCT DICOM object using the CtProperties object
    %to determine the interpolation grid.
    
    properties (SetAccess  = 'private', GetAccess = 'public')
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
    end
    
    methods
        function me = RtStruct(struct, pixelSpacing, Origin, Axis, Dimensions)
            me = me.setPixelSpacing(pixelSpacing);
            me = me.setOrigin(Origin);
            me = me.setAxis(Axis);
            me = me.setDimensions(Dimensions);
            me = me.parseRTStruct(struct);
        end
        
        function out = getRoiMask(me, in)
            
            [index, name] = me.selectRoiNameIndex(in);
            
            if me.rendered{index,2} == 0;
                %suppress the warning on functions genvarname.
                %it is a deprecate function that can be replace once we
                %switch to a newer version of Matlab.
                slices = me.getSlicesForRoi(name);
                if isempty(slices)
                    out = [];
                    return
                end
                rawMask = me.calculateBitmask(slices);
                %bitshift the mask to prevent memory issues
                me.bitMasks = me.bitMasks + uint64(rawMask.*(2^(index-1)));
                me.rendered{index,2} = 1;
            end
            out = double(bitget(me.bitMasks, index));
        end
		
		function image = addRoiToGrayScaleMap(me, image, ctSlice, in)
            ContourMask = me.getRoiMask(in);
            ContourMaskSlice = double(flipud(squeeze(ContourMask(:,ctSlice,:))'));
            ContourList = contourc(double(1:me.Dimensions(1)), double(1:me.Dimensions(3))...
                , ContourMaskSlice, [1.0 1.0]);
            ColorMap = me.getColorMap(in);
            
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
        
        function sliceNrs = findUsedSlices(me, in, first)
            ContourMask = me.getRoiMask(in);
            sliceNrs = [];
            for i = 1:me.Dimensions(2)
                ContourMaskSlice = squeeze(ContourMask(:,i,:));
                if max(max(ContourMaskSlice)) == 1
                    sliceNrs = [sliceNrs, i]; %#ok<AGROW>
                    if first == true
                        return;
                    end
                end
            end
        end
        
        function out = get.PixelSpacingi(me)
            out = me.PixelSpacing(1);
        end
        
        function out = get.PixelSpacingj(me)
            out = me.PixelSpacing(2);
        end
        
        function out = get.PixelSpacingk(me)
            out = me.PixelSpacing(3);
        end
        
        function out = get.Axis(me)
            out.Axisi = me.Axisi;
            out.Axisj = me.Axisj;
            out.Axisk = me.Axisk;
        end 
    end
    
    methods (Access = private)
%         function me = parseGrid(me, grid)
%             if grid.hasAllProperties
%                 me.calcGrid = grid;
%                 me.bitMasks = zeros(grid.Dimensions ,'uint64');
%                 me.hasCalcGrid = true;
%             end
%         end
        function me = setPixelSpacing(me, pixelSpacing)
            me.PixelSpacing = pixelSpacing;
        end
        
        function me = setOrigin(me, Origin)
            me.Origin = Origin;
        end
        
        function me = setDimensions(me, Dimensions)
            me.Dimensions = Dimensions;
            me.bitMasks = zeros(me.Dimensions ,'uint64');
        end

        function me = setAxis(me, Axis)
            me.Axisi = Axis.Axisi;
            me.Axisj = Axis.Axisj;
            me.Axisk = Axis.Axisk;
        end
        
        function me = parseRTStruct(me, struct)
            %check if struct is a read RTSTRUCT of filelocation
            if ~isfield(struct, 'DicomHeader')
                if ~exist(struct, 'file')
                    structString = regexprep(struct,'\','\\\');
                    throw(MException('Matlab:FileNotFound', ['DICOM RT-STRUCT file ''' structString ''' not found.''']));
                end
                %prevent errors with certain structure sets. The
                %warning is not catch-able so cannot disable only for
                %the problematic structure sets.
                struct = dicominfo(struct, 'UseVRHeuristic',false);
                struct = read_dicomrtstruct([] ,'dicomheader', struct);
            end
            
            me = me.setSliceCollection(struct.Struct);
            me = me.parseColorSettingFromHeader(struct.DicomHeader);
            me = me.setRenderList();
            me.nrOfRois = length(me.sliceCollection);
        end
        
        function me = setRenderList(me)
           for i = 1:length(me.sliceCollection)
               me.rendered{i, 1} = me.sliceCollection(i).Name;
               me.rendered{i, 2} = 0;
           end
        end
		
		function me = setSliceCollection(me, Struct)
            for i = 1:length(Struct)
                index = Struct(i).Number;
                slices(index) = Struct(i); %#ok<AGROW>
            end
            me.sliceCollection = slices;
        end
		
		function me = parseColorSettingFromHeader(me, header)
            for i = 1:length(me.sliceCollection)
                try
                    index = header.ROIContourSequence.(['Item_' num2str(i)]).ReferencedROINumber;
                    color = header.ROIContourSequence.(['Item_' num2str(i)]).ROIDisplayColor./256;
                    me.sliceCollection(index).color = color;
                catch EM
                    warning(['no colormap found, set to default, MATLAB message: ' EM.message]);
                    me.sliceCollection(index).color = 'red';
                end
            end
        end
  
        function out = calculateBitmask(me, Slices)
            %improves readablity of the calculations
            i = me.PixelSpacingi;
            k = me.PixelSpacingk;

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
                out = VolumeResample(structureData,XStruct,YStruct,ZStruct,me.Axisi,me.Axisj,me.Axisk);
                out (out >= 0.5) = 1;
                out (out < 0.5) = 0;
            else
                throw(MException('RtStruct:DelineationData', ['No 3D delineation found, [x, y, z]: ' ...
                    num2str(length(XStruct)) ',' num2str(length(YStruct)) ',' num2str(length(ZStruct))]));
            end
        end
        
        function out = getSlicesForRoi(me, name)
            % Extract the slices for the desired structure
            index = me.getRoiIndexForName(name);
        
            % Although you would expect only one slice base on the
            % property name, it does contain a set of slices. This is
            % caused by the weird naming scheme in read_dicomrtstruct.m
            out = me.sliceCollection(index).Slice;
        end
        
        function index = getRoiIndexForName(me, name)
            index = structfind(me.sliceCollection, 'Name', name);
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
                        
		function out = getColorMap(me, in)
            % Extract the slices for the desired structure
            [index, ~] = me.selectRoiNameIndex(in);
            out = me.sliceCollection(index).color;
            if isempty(out)
                out = [1;1;0];%default red
            end
        end
        
        function [index, name] = selectRoiNameIndex(me, in)
            if ischar(in)
                name = in;
                index = me.getRoiIndexForName(name); 
            elseif length(in)== 1 && isnumeric(in)
                if in <= me.nrOfRois
                    index = in;
                    name = me.sliceCollection(index).Name;
                else
                    throw(MException('RtStruct:InvalidInput', ...
                    ['the index (' num2str(in) ') provided is not present for this RtStruct(' num2str(length(me.nrOfRois)) ')']));
                end
            else
                throw(MException('RtStruct:InvalidInput', ...
                    ['input ' class(in) ' is invalid, please provide a structure index or name']));    
            end
        end
    end    
end

