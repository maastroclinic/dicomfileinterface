classdef RtImage < DicomObj
    %RTIMAGE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        referencedRtPlanUid
    end
    
    methods
        function this = RtImage(varargin)
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            
            this = constructorParser(this, 'rtimage', varargin{1}, varargin{2});
        end
        
        function out = get.referencedRtPlanUid(this)
            out = [];
            if isfield(this.dicomHeader, 'ReferencedRTPlanSequence')
                out = this.dicomHeader.ReferencedRTPlanSequence.Item_1.ReferencedSOPInstanceUID;
            end            
        end
    end
end

