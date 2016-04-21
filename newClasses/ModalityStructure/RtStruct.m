classdef RtStruct < DicomObj
    %RTSTRUCT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function this = RtStruct(varargin)
            if nargin == 0 %preserve standard empty constructor
                return;
            end
                
            this = constructorParser(this, 'rtstruct', varargin{1}, varargin{2});
        end
    end
    
end