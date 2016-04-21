classdef RtDose < DicomObj
    %RTDOSE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function this = RtDose(varargin)
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            
            this = constructorParser(this, 'rtdose', varargin{1}, varargin{2});
        end
    end
    
end

