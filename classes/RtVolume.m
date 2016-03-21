classdef (Abstract) RtVolume
    
    properties (SetAccess  = 'protected', GetAccess = 'public')
        name;
        volume;
        calcGrid;
        
        bitmask;
        roiValues;
        
        edgePixels = 5;
       
        iCompressed = [];
        jCompressed = [];
        kCompressed = []; 
        
        hasDelineation = false;
        hasFittedRoiValues  = false;
        
        hasCompressedBitmask     = false;
        hasCompressedRoiValues   = false;
    end
    
    methods
        function [i_calc, i_value, i_rtstruct] = parseVargarin(~, variableInput)
            i_calc = [];
            i_value = [];
            i_rtstruct = [];
            for i= 1:length(variableInput)
                switch class(variableInput{i})
                    case 'CalculationGrid'
                        i_calc = i;
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
        
        function out = get.name(me)
            out = me.name;
        end

        function out = get.volume(me)
            % in cc/ml
            if me.hasDelineation
                out = nansum(me.bitmask(:)) * prod(me.calcGrid.PixelSpacing);
            else
                out = NaN;
            end
        end
        
        function a = plus(a, b)
            % PLUS Sum two AbstractVolume objects
            try
                if isequal(a.calcGrid.Dimensions, b.calcGrid.Dimensions) && ~isnan(a.volume) && ~isnan(b.volume)
                    a = a.decompress();
                    b = b.decompress();
                    
                    a.name = [a.name '+' b.name];
                    a.bitmask = a.bitmask | b.bitmask;
                    if (a.canCalculateRoiValues && b.canCalculateRoiValues)
                        aValues = a.roiValues;
                        bValues= b.roiValues;
                        aValues(isnan(aValues)) = bValues(isnan(aValues));
                        %this dodgy logic ensures that the entire dose cube
                        %does not have to be in memory. the dose empty dose
                        %values of A will be filled with the dose values
                        %of B (which can be empty to) resulting in the
                        %combined dose cube.
                        a.roiValues = aValues;
                    end
                    a.compress();
                else
                    throw(MException('AbstractVolume:PlusDimensionMismatch', ['Could not add ' a.name ' from ' b.name '. Dimension mismatch: ' ...
                        a.name ': ' num2str(a.calcGrid.Dimensions)...
                        b.name ': ' num2str(b.calcGrid.Dimensions)]));
                end
            catch EM
                throw(EM);
            end
        end
        
        function a = minus(a, b)
            % MINUS Subtract two AbstractVolume objects
            try
                if isequal(a.calcGrid.Dimensions, b.calcGrid.Dimensions) && ~isnan(a.volume) && ~isnan(b.volume)
                    a = a.decompress();
                    b = b.decompress();
                    
                    a.name = [a.name '-' b.name];
                    a.bitmask = a.bitmask &~ b.bitmask;
                    if (a.canCalculateRoiValues && b.canCalculateRoiValues)
                        a.roiValues(a.bitmask == 0) = NaN;
                    end
                    a.compress();
                else
                    throw(MException('AbstractVolume:MinusDimensionMismatch', ['Could not substract ' a.name ' from ' b.name '. Dimension mismatch: ' ...
                        a.name ': ' num2str(a.calcGrid.Dimensions)...
                        b.name ': ' num2str(b.calcGrid.Dimensions)]));
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

            if me.hasFittedRoiValues && ~me.hasCompressedRoiValues
                me.roiValues = me.roiValues(me.iCompressed, me.jCompressed, me.kCompressed);
                me.hasCompressedRoiValues = true;
            end
        end
        
        function me = decompress(me)
            if me.hasDelineation && me.hasCompressedBitmask
                decompMasp = zeros(me.calcGrid.Dimensions(1), me.calcGrid.Dimensions(2), me.calcGrid.Dimensions(3));
                decompMasp(me.iCompressed, me.jCompressed, me.kCompressed) = me.bitmask;
                me.bitmask = decompMasp;
                me.hasCompressedBitmask = false;
            end
            
            if me.hasFittedRoiValues && me.hasCompressedRoiValues
                decompMasp = zeros(me.calcGrid.Dimensions(1), me.calcGrid.Dimensions(2), me.calcGrid.Dimensions(3));
                decompMasp(:) = NaN;
                decompMasp(me.iCompressed, me.jCompressed, me.kCompressed) = me.roiValues;
                me.roiValues = decompMasp;
                me.hasCompressedRoiValues = false;
            end
        end

    end
    
    methods (Access = protected)
        function me = setcalcGrid(me, calcGrid)
            me.calcGrid = calcGrid;
        end
        
        function me = parseRtStruct(me, rtStruct, in)
            if me.calcGrid == rtStruct.calcGrid
                me.bitmask  = rtStruct.getRoiMask(in);
                me.hasDelineation = true;
            else
                throw(MException('AbstractVolume:DimensionMismatch', 'RtStruct does not match AbstractVolume calcGrid'));
            end
        end
        
        function out = canCalculateRoiValues(me)
            out = (me.hasDelineation && me.hasFittedRoiValues && ~isnan(me.volume));
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
            if (x(end)+me.edgePixels) > me.calcGrid.Dimensions(dim)
                last = me.calcGrid.Dimensions(dim);
            else
                last = x(end)+me.edgePixels;
            end
            x = first:last;
        end
    end
end

