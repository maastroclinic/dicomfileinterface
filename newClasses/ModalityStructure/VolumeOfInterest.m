classdef VolumeOfInterest < Image
    %VOLUMEOFINTEREST
    
    properties
        xCompressed = [];
        yCompressed = [];
        zCompressed = [];
        
        uncompressedImageData;
        
        EDGE_BUFFER = 5;
    end
    
    methods
        function this = VolumeOfInterest(varargin)
            [pixelSpacingX, pixelSpacingY, pixelSpacingZ, realX, realY, realZ, imageData] = VolumeOfInterest.parseConstructorInput(varargin);
            this = this@Image(pixelSpacingX, pixelSpacingY, pixelSpacingZ, realX, realY, realZ, imageData);
            this = this.compressBitmask();
        end
       
        function this = addImageData(this, imageData)
            this = this.addImageData@Image(imageData);
            this = this.compressBitmask();
        end
        
        function out = get.uncompressedImageData(this)
            out = zeros(this.columns, this.slices, this.rows);
            out(this.xCompressed, this.yCompressed, this.zCompressed) = this.imageData;
        end
    end
    
    methods (Access = protected)
        function this = compressBitmask(this)
            [x,y,z] = findVolumeEdges(this);
            this.xCompressed = x;
            this.yCompressed = y;
            this.zCompressed = z;
            this.imageData = this.imageData(x,y,z);
        end
        
        function [x,y,z] = findVolumeEdges(this)
            [x,y,z]=ind2sub(size(this.imageData),find(this.imageData));
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
        
    end
    
    methods (Static)
        function [pixelSpacingX, pixelSpacingY, pixelSpacingZ, realX, realY, realZ, imageData] = parseConstructorInput(input)
            if isempty(input) %preserve standard empty constructor
                pixelSpacingX = double([]);
                pixelSpacingY = double([]);
                pixelSpacingZ = double([]);
                realX = double([]);
                realY = double([]);
                realZ = double([]);
                imageData = [];
            elseif length(input) == 1 && isa(input{1}, 'Image')
                pixelSpacingX = input{1}.pixelSpacingX;
                pixelSpacingY = input{1}.pixelSpacingY;
                pixelSpacingZ = input{1}.pixelSpacingZ;
                realX = input{1}.realX;
                realY = input{1}.realY;
                realZ = input{1}.realZ;
                imageData = input{1}.imageData;
            elseif length(input) == 7
                pixelSpacingX = input{1};
                pixelSpacingY = input{2};
                pixelSpacingZ = input{3};
                realX = input{4};
                realY = input{5};
                realZ = input{6};
                imageData = input{7};
            else
                throw(MException('MATLAB:VolumeOfInterest:parseConstructorInput', ['Invalid constructor, empty, Image ' ...
                                 'based or the standard Image constructor are supported']))
            end
        end
    end
    
end

