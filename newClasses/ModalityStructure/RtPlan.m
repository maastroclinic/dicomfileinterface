classdef RtPlan < DicomObj
    %RTPLAN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function this = RtPlan(varargin)
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            
            this = constructorParser(this, 'rtplan', varargin{1}, varargin{2});
        end
        
        function readDicomData(~)
            warning('this standard dicom function is overwritten because the rtstruct dicom object does not contain an image block');
        end
    end
    
end

