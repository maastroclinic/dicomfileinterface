classdef VolumeOfInterest < Image
    %VOLUMEOFINTEREST
    
    properties
        xCompressed = []
        yCompressed = []
        zCompressed = []
        
        uncompressedPixelData
        EDGE_BUFFER = 5
    end
    
    methods
        function this = VolumeOfInterest(varargin)
            [pixelSpacingX, pixelSpacingY, pixelSpacingZ, realX, realY, realZ, pixelData] = VolumeOfInterest.parseConstructorInput(varargin);
            this = this@Image(pixelSpacingX, pixelSpacingY, pixelSpacingZ, realX, realY, realZ, pixelData);
        end
       
        function this = addpixelData(this, pixelData)
            this = this.addpixelData@Image(pixelData);
            this = this.compressBitmask();
        end
        
        function out = get.uncompressedPixelData(this)
            out = false(this.columns, this.slices, this.rows);
            out(this.xCompressed, this.yCompressed, this.zCompressed) = this.pixelData;
        end
        
        function this = compress(this)
            [x,y,z] = findVolumeEdges(this);
            if ~isempty(x)
                this.xCompressed = x;
                this.yCompressed = y;
                this.zCompressed = z;
                this.pixelData = this.pixelData(x,y,z);
            else
                this.xCompressed = 1:this.columns;
                this.yCompressed = 1:this.slices;
                this.zCompressed = 1:this.rows;
            end
        end
        
        function this = addPixelData(this, pixelData)            
            if size(pixelData,1) ~= this.columns || ...
               size(pixelData,2) ~= this.slices || ...
               size(pixelData,3) ~= this.rows
                throw(MException('MATLAB:VolumeOfInterest:addPixelData', ['Dimension mismatch! The real axis properties' ...
                                  ' do not match the dimensions of the image you are trying to store']));
            end
            
            try
                this.pixelData = logical(pixelData);
                this = this.compress();
            catch
                this.pixelData = [];
                warning('could not convert pixel data to logical');
            end
            
        end
        
        function out = plus(first, second)
            out = combine(first, second, '+');
        end

        function out = minus(first, second)
            out = combine(first, second, '-');
        end
    end
    
    methods (Access = protected)
        function [x,y,z] = findVolumeEdges(this)
            [x,y,z]=ind2sub(size(this.pixelData),find(this.pixelData));
            x = sort(unique(x));
            y = sort(unique(y));
            z = sort(unique(z));
            
            if ~isempty(x)   
                x = this.determineIndexArray(x, this.columns);
                y = this.determineIndexArray(y, this.slices);
                z = this.determineIndexArray(z, this.rows);
            end
        end
        
        function x = determineIndexArray(this, x, upperLimit)
            if (x(1)-this.EDGE_BUFFER) < 1
                first = 1;
            else
                first = x(1)-this.EDGE_BUFFER;
            end
            if (x(end)+this.EDGE_BUFFER) > upperLimit
                last = upperLimit;
            else
                last = x(end)+this.EDGE_BUFFER;
            end
            x = first:last;
        end
        
        %overwrite function of superclass to ensure the volume is correct
        function out = calculateVolume(this)
            out = sum(this.pixelData(:) .* (this.pixelSpacingX*this.pixelSpacingY*this.pixelSpacingZ));
        end
        
        function out = combine(first, second, operation)
            if isequal(first.realX, second.realX) && ...
                    isequal(first.realY, second.realY) && ...
                    isequal(first.realZ, second.realZ)
                
                if strcmp('+', operation)
                    new = first.uncompressedPixelData | second.uncompressedPixelData;
                else
                    new = first.uncompressedPixelData &~ second.uncompressedPixelData;
                end

                out = first;
                out = out.addPixelData(new);
            else
                throw(MException('MATLAB:VolumeOfInterest:combine', 'dimensions do not agree'));
            end
        end
    end
    
    methods (Static)
        function [pixelSpacingX, pixelSpacingY, pixelSpacingZ, realX, realY, realZ, pixelData] = parseConstructorInput(input)
            if isempty(input) %preserve standard empty constructor
                pixelSpacingX = double([]);
                pixelSpacingY = double([]);
                pixelSpacingZ = double([]);
                realX = double([]);
                realY = double([]);
                realZ = double([]);
                pixelData = [];
            elseif length(input) == 1 && isa(input{1}, 'Image')
                pixelSpacingX = input{1}.pixelSpacingX;
                pixelSpacingY = input{1}.pixelSpacingY;
                pixelSpacingZ = input{1}.pixelSpacingZ;
                realX = input{1}.realX;
                realY = input{1}.realY;
                realZ = input{1}.realZ;
                pixelData = input{1}.pixelData;
            elseif length(input) == 7
                pixelSpacingX = input{1};
                pixelSpacingY = input{2};
                pixelSpacingZ = input{3};
                realX = input{4};
                realY = input{5};
                realZ = input{6};
                pixelData = input{7};
            else
                throw(MException('MATLAB:VolumeOfInterest:parseConstructorInput', ['Invalid constructor, empty, Image ' ...
                                 'based or the standard Image constructor are supported']))
            end
        end
    end
end

