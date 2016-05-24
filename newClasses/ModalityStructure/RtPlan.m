classdef RtPlan < DicomObj
    %RTPLAN
    
    properties
        planLabel
        rtStructReferenceUid
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

