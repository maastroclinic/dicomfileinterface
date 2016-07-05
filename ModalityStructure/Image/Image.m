classdef Image
    %IMAGE contains sampled information of a real world space. 
    
    properties 
        pixelSpacingX %in cm
        pixelSpacingY %in cm
        pixelSpacingZ %in cm
        realX %in cm
        realY %in cm
        realZ %in cm
    end
    
    properties (SetAccess = 'protected')
        rows
        slices
        columns
        pixelData
        is3d
        volume
    end
    
    methods
        function this = Image(pixelSpacingX, pixelSpacingY, pixelSpacingZ, realX, realY, realZ, pixelData)
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            
            this.pixelSpacingX = pixelSpacingX;
            this.pixelSpacingY = pixelSpacingY;
            this.pixelSpacingZ = pixelSpacingZ;
            
            this.realX = realX;
            this.realY = realY;
            this.realZ = realZ;
            
            if ~isempty(pixelData)
                this = this.addPixelData(pixelData);
            end
        end
        
        function this = set.pixelSpacingX(this, pixelSpacing)
            if ~isnumeric(pixelSpacing)
                throw(MException('MATLAB:Image:pixelSpacingX', 'pixelSpacingX has to be a numeric value'));
            end
            this.pixelSpacingX = pixelSpacing;
        end
        
        function this = set.pixelSpacingY(this, pixelSpacing)
            if ~isnumeric(pixelSpacing)
                throw(MException('MATLAB:Image:pixelSpacingY', 'pixelSpacingY has to be a numeric value'));
            end
            this.pixelSpacingY = pixelSpacing;
        end
        
        function this = set.pixelSpacingZ(this, pixelSpacing)
            if ~isnumeric(pixelSpacing)
                throw(MException('MATLAB:Image:pixelSpacingZ', 'pixelSpacingZ has to be a numeric value'));
            end
            this.pixelSpacingZ = pixelSpacing;
        end
        
        function this = set.realX(this, real)
            if ~isnumeric(real)
                throw(MException('MATLAB:Image:realX', 'realX has to be a numeric value'));
            end
            this.realX = real;
        end
        
        function this = set.realY(this, real)
            if ~isnumeric(real)
                throw(MException('MATLAB:Image:realY', 'realY has to be a numeric value'));
            end    
            this.realY = real;
        end
        
        function this = set.realZ(this, real)
            if ~isnumeric(real)
                throw(MException('MATLAB:Image:realZ', 'realZ has to be a numeric value'));
            end
            this.realZ = real;
        end
        
        function out = get.rows(this)
            out = length(this.realZ);
        end
        
        function out = get.columns(this)
            out = length(this.realX);
        end
        
        function out = get.slices(this)
            out = length(this.realY);
        end
        
        function out = get.is3d(this)
            out = false; 
            if this.rows > 1 && this.columns > 1 && this.slices > 1
                out = true;
            end
        end
        
        function this = addPixelData(this, pixelData)
            if size(pixelData,1) ~= this.columns || ...
               size(pixelData,2) ~= this.slices || ...
               size(pixelData,3) ~= this.rows
                throw(MException('MATLAB:Image:pixelData', ['Dimension mismatch! The real axis properties' ...
                                  ' do not match the dimensions of the image you are trying to store']));
            end
            
            this.pixelData = pixelData;
        end
        
        function out = get.volume(this)
            out = this.calculateVolume();
        end
    end
    
    methods (Access = 'protected')
        function out = calculateVolume(this)
            out = sum(~isnan(this.pixelData(:)) .* (this.pixelSpacingX*this.pixelSpacingY*this.pixelSpacingZ));
        end
    end
end