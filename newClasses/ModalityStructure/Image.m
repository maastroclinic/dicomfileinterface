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
    
    methods
        function this = Image(varargin)
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            
            
        end
    end
    
end

