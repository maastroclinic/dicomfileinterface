classdef RtDose < DicomObj
    %RTDOSE 
    
    properties
        referencedRtPlanUid
    end
    
    methods
        function this = RtDose(varargin)
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            
            this = constructorParser(this, 'rtdose', varargin{1}, varargin{2});
        end
        
        function out = get.referencedRtPlanUid(this)
            out = [];
            if isfield(this.dicomHeader, 'ReferencedRTPlanSequence')
                out = this.dicomHeader.ReferencedRTPlanSequence.Item_1.ReferencedSOPInstanceUID;
            end            
        end
        
    end
    
end

