classdef Image
    
    properties (SetAccess  = 'protected', GetAccess = 'public')
        volume;
        %------------------
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
        %--------------
        bitmask;
        maskedData;
        rawData;
        
        edgePixels = 5;
       
        iCompressed = [];
        jCompressed = [];
        kCompressed = []; 
        
        hasDelineation = false;
        hasImageData  = false;
        
        hasCompressedBitmask     = false;
        hasCompressedRoiValues   = false;
        
        name;
    end
    
    methods
        function me = Image(name, imageBitmask, imageData, pixelSpacing, Origin, Axis, Dimensions)
            me.volume = NaN;
            me = me.setName(name);      
            me = me.setcalcGrid(pixelSpacing, Origin, Axis, Dimensions);
            me = me.parseImageBitmask(imageBitmask);
            if ~isempty(imageData)
                me = me.parseImage(imageData);
            end
            me = me.compress();
        end
        
        function [i_calc, i_value, i_rtstruct] = parseVargarin(~, variableInput)
            i_calc = [];
            i_value = [];
            i_rtstruct = [];
            for i= 1:length(variableInput)
                switch class(variableInput{i})
                    case 'RtDose'
                        i_value = i;
                    case 'Ct'
                        i_value = i;
                    case 'RtStruct'
                        i_rtstruct = i;
                end
            end
        end
        
        function me = setName(me, name)
            name = strtrim(name);
            if (~isempty(name))
                me.name = name;
            end
        end
        
        function me = set.edgePixels(me, nr)
            if isnumeric(nr) && size(nr,1) == 1 && size(nr,2) == 1
                me.edgePixels = nr;
            else
                throw(MException('AbstractVolume:InvalidInput', ...
                            'edgePixels must be a single value double'));
            end
        end
        
        function me = addRtStruct(me, struct, name)
            me = me.parseRtStruct(struct, name);
        end
        
        function me = addRtStructIndex(me, struct, index)
            me = me.parseRtStruct(struct, index);
        end
        
        function me = addImageData(me, imageData)
            me = me.parseImage(imageData);
        end
        
        function out = get.name(me)
            out = me.name;
        end

        function out = get.volume(me)
            % in cc/ml
            if me.hasDelineation
                out = nansum(me.bitmask(:)) * prod(me.PixelSpacing);
            else
                out = NaN;
            end
        end
        
        function a = plus(a, b)
            % PLUS Sum two AbstractVolume objects
            try
                if isequal(a.Dimensions, b.Dimensions) && ~isnan(a.volume) && ~isnan(b.volume)
                    a = a.decompress();
                    b = b.decompress();
                    
                    a.name = [a.name '+' b.name];
                    a.bitmask = a.bitmask | b.bitmask;
                    if (a.canCalculateRoiValues && b.canCalculateRoiValues)
                        aValues = a.maskedData;
                        bValues= b.maskedData;
                        aValues(isnan(aValues)) = bValues(isnan(aValues));
                        %this dodgy logic ensures that the entire dose cube
                        %does not have to be in memory. the dose empty dose
                        %values of A will be filled with the dose values
                        %of B (which can be empty to) resulting in the
                        %combined dose cube.
                        a.maskedData = aValues;
                    end
                    a.compress();
                else
                    throw(MException('AbstractVolume:PlusDimensionMismatch', ['Could not add ' a.name ' from ' b.name '. Dimension mismatch: ' ...
                        a.name ': ' num2str(a.Dimensions)...
                        b.name ': ' num2str(b.Dimensions)]));
                end
            catch EM
                throw(EM);
            end
        end
        
        function a = minus(a, b)
            % MINUS Subtract two AbstractVolume objects
            try
                if isequal(a.Dimensions, b.Dimensions) && ~isnan(a.volume) && ~isnan(b.volume)
                    a = a.decompress();
                    b = b.decompress();
                    
                    a.name = [a.name '-' b.name];
                    a.bitmask = a.bitmask &~ b.bitmask;
                    if (a.canCalculateRoiValues && b.canCalculateRoiValues)
                        a.maskedData(a.bitmask == 0) = NaN;
                    end
                    a.compress();
                else
                    throw(MException('AbstractVolume:MinusDimensionMismatch', ['Could not substract ' a.name ' from ' b.name '. Dimension mismatch: ' ...
                        a.name ': ' num2str(a.Dimensions)...
                        b.name ': ' num2str(b.Dimensions)]));
                end
            catch EM
                throw(EM);
            end
        end
        
        function me = compress(me)
            if ~me.hasCompressedBitmask || ...
                    ~me.hasCompressedRoiValues
                
                me = me.findVolumeEdges();
                if isempty(me.iCompressed)
                    return;
                end
            else
                return;
            end
            
            if me.hasDelineation && ~me.hasCompressedBitmask
                me.bitmask = me.bitmask(me.iCompressed, me.jCompressed, me.kCompressed);
                me.hasCompressedBitmask = true;
            end

            if me.hasImageData && ~me.hasCompressedRoiValues
                me.maskedData = me.maskedData(me.iCompressed, me.jCompressed, me.kCompressed);
                me.hasCompressedRoiValues = true;
            end
        end
        
        function me = decompress(me)
            if me.hasDelineation && me.hasCompressedBitmask
                decompMasp = zeros(me.Dimensions(1), me.Dimensions(2), me.Dimensions(3));
                decompMasp(me.iCompressed, me.jCompressed, me.kCompressed) = me.bitmask;
                me.bitmask = decompMasp;
                me.hasCompressedBitmask = false;
            end
            
            if me.hasImageData && me.hasCompressedRoiValues
                decompMasp = zeros(me.Dimensions(1), me.Dimensions(2), me.Dimensions(3));
                decompMasp(:) = NaN;
                decompMasp(me.iCompressed, me.jCompressed, me.kCompressed) = me.maskedData;
                me.maskedData = decompMasp;
                me.hasCompressedRoiValues = false;
            end
        end

    end
    
    methods (Access = protected)
        function me = parseImage(me, image)
            if ~me.hasImageData
                if 1 == 1 %TODO, i want to throw this dimension but do not know how to check it yet
                    me.hasImageData = true;
                    me.maskedData = me.calculateRoiValues(image);
                else
                    throw(MException('RtVolume:DimensionMismatch', 'RtDose does not match RtVolume calcGrid'));
                end
            else
                throw(MException('RtVolume:rtDoseOverwrite', 'This rtVolume already has a fitted dose, cannot overwrite.'));
            end
        end
        
        function me = setcalcGrid(me, pixelSpacing, Origin, Axis, Dimensions)
            me = me.setPixelSpacing(pixelSpacing);
            me = me.setOrigin(Origin);
            me = me.setAxis(Axis);
            me = me.setDimensions(Dimensions);
            me.hasDelineation = true;
        end
        
        function me = setPixelSpacing(me, pixelSpacing)
            me.PixelSpacing = pixelSpacing;
        end
        
        function me = setOrigin(me, Origin)
            me.Origin = Origin;
        end
        
        function me = setDimensions(me, Dimensions)
            me.Dimensions = Dimensions;
        end

        function me = setAxis(me, Axis)
            me.Axisi = Axis.Axisi;
            me.Axisj = Axis.Axisj;
            me.Axisk = Axis.Axisk;
        end
        
        function me = parseImageBitmask(me, bitmask)
            if 1 == 1 %TODO, i want to throw this dimension but do not know how to check it yet
                me.bitmask  = bitmask;
            else
                throw(MException('AbstractVolume:DimensionMismatch', 'RtStruct does not match AbstractVolume calcGrid'));
            end
        end
        
        function out = canCalculateRoiValues(me)
            out = (me.hasDelineation && me.hasImageData && ~isnan(me.volume));
        end
        
        function out = calculateRoiValues(me, values)
            if me.canCalculateRoiValues
                A = double(me.bitmask);
                A(A==0) = NaN;

                if me.hasCompressedBitmask
                    values = values(me.iCompressed, me.jCompressed, me.kCompressed);
                end

                out = values .* A;
            end
        end
        
        function me = findVolumeEdges(me)
            [i,j,k]=ind2sub(size(me.bitmask),find(me.bitmask));
            i = sort(unique(i));
            j = sort(unique(j));
            k = sort(unique(k));
            
            if ~isempty(i)   
                i = me.determineIndexArray(i, 1);
                j = me.determineIndexArray(j, 2);
                k = me.determineIndexArray(k, 3);
            end
            
            me.iCompressed = i;
            me.jCompressed = j;
            me.kCompressed = k;
        end
        
        function x = determineIndexArray(me, x, dim)
            if (x(1)-me.edgePixels) < 1
                first = 1;
            else
                first = x(1)-me.edgePixels;
            end
            if (x(end)+me.edgePixels) > me.Dimensions(dim)
                last = me.Dimensions(dim);
            else
                last = x(end)+me.edgePixels;
            end
            x = first:last;
        end
    end
end

