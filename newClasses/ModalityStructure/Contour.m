classdef Contour
    %CONTOUR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        number
        item
        name
        
        realX
        realY
        realZ
        
        
    end
    
    methods
        function this = Contour(varargin)
            if nargin == 0 %preserve standard empty constructor
                return;
            end
        end
    end
    
end

