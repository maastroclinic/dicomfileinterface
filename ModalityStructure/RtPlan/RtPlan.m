classdef RtPlan < DicomObj
    %RTPLAN represents a RtPlan DicomObj
    %
    %CONSTRUCTOR:
    % this = RtPlan(dicomItem, useVrHeuristics) creates a RtPlan object
    %  using the full file path (or a DicomObj) and boolean to deterine the use of VR Heuristics
    %
    % See also: DICOMOBJ
    
    properties
        planLabel
        rtStructReferenceUid
    end
    
    methods
        function this = RtPlan(dicomItem, useVrHeuristics)
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            
            this = constructorParser(this, 'rtplan', dicomItem, useVrHeuristics);
        end
        
        function readDicomData(~)
            warning('this standard dicom function is overwritten because the rtstruct dicom object does not contain an image block');
        end
        
        function out = get.planLabel(this)
            out = this.dicomHeader.RTPlanLabel; 
        end
        
        function out = get.rtStructReferenceUid(this)
            out = [];
            if isfield(this.dicomHeader, 'ReferencedStructureSetSequence')
                out = this.dicomHeader.ReferencedStructureSetSequence.Item_1.ReferencedSOPInstanceUID;
            end
        end
    end
    
end

