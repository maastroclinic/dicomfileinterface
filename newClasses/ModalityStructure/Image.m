classdef Image
    %IMAGE contains sampled information of a real world space. 
    
    properties
        pixelSpacingX %in cm
        pixelSpacingY %in cm
        pixelSpacingZ %in cm
        
        realX %in cm
        realY %in cm
        realZ %in cm
        
        imageData;
    end
    
    methods
        function this = Image(pixelSpacingX, pixelSpacingY, pixelSpacingZ, ...
                              realX, realY, realZ, imageData)
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
    end
end