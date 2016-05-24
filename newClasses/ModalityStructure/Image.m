classdef Image
    %IMAGE contains sampled information of a real world space. 
    
    properties (SetAccess = 'protected')
        pixelSpacingX %in cm
        pixelSpacingY %in cm
        pixelSpacingZ %in cm
        realX %in cm
        realY %in cm
        realZ %in cm
        rows
        slices
        columns
        imageData
    end
    
    methods
        function this = Image(pixelSpacingX, pixelSpacingY, pixelSpacingZ, realX, realY, realZ, imageData)
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            
            this.pixelSpacingX = pixelSpacingX;
            this.pixelSpacingY = pixelSpacingY;
            this.pixelSpacingZ = pixelSpacingZ;
            
            this.realX = realX;
            this.realY = realY;
            this.realZ = realZ;
            
            if ~isempty(imageData)
                this.imageData = imageData;
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
        
        function this = addImageData(this, imageData)
            if size(imageData,1) ~= this.rows || ...
               size(imageData,2) ~= this.slices || ...
               size(imageData,3) ~= this.columns
                throw(MException(['MATLAB:Image:imageData', 'Dimension mismatch! The real axis properties' ...
                                  ' do not match the dimensions of the image you are trying to store']));
            end
            
            this.imageData = imageData;
        end
    end
end