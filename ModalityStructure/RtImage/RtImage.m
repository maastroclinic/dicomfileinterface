classdef RtImage < DicomObj
    %RTIMAGE represents a RtImage DicomObj
    %
    %CONSTRUCTOR:
    % this = RtImage(dicomItem, useVrHeuristics) creates a RtImage object
    %  using the full file path (or a DicomObj) and boolean to deterine the use of VR Heuristics
    %
    % See also: DICOMOBJ
    properties
        referencedRtPlanUid
    end
    
    methods
        function this = RtImage(dicomItem, useVrHeuristics)
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            
            this = constructorParser(this, 'rtimage', dicomItem, useVrHeuristics);
        end
        
        function out = get.referencedRtPlanUid(this)
            out = [];
            if isfield(this.dicomHeader, 'ReferencedRTPlanSequence')
                out = this.dicomHeader.ReferencedRTPlanSequence.Item_1.ReferencedSOPInstanceUID;
            end            
        end
    end
end

