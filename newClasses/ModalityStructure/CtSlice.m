classdef CtSlice < DicomObj
    %CTSLICE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        instanceNumber;
    end
    
    methods
        function this = CtSlice(varargin)
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            
            this = constructorParser(this, 'ct', varargin{1}, varargin{2});
        end
        
        function out = get.instanceNumber(this)
            out = this.dicomHeader.InstanceNumber;
        end
    end
    
end

