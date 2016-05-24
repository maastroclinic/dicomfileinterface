classdef RtStruct < DicomObj
    %RTSTRUCT Representation of a DICOM RTSTRUCT
    
    properties
        structureSetSequence
        observationSequence
        contourSequence
        contourNames
        referencedImageSeriesUid
%         referencedFirstImageUid
    end
    
    methods
        function this = RtStruct(varargin)
            if nargin == 0 %preserve standard empty constructor
                return;
            end
                
            this = constructorParser(this, 'rtstruct', varargin{1}, varargin{2});
        end
        
        function readDicomData(~)
            warning('this standard dicom function is overwritten because the rtstruct dicom object does not contain an image block');
        end
        
        function out = dicomHeaderForRoiNumber(this, number)
            out = [];
            
            item = this.itemForRoiNumber(this.structureSetSequence, number, 'ROINumber');
            out = this.addFieldsToOutput(out, this.structureSetSequence, item);
            
            item = this.itemForRoiNumber(this.observationSequence, number, 'ReferencedROINumber');
            out = this.addFieldsToOutput(out, this.observationSequence, item);
            
            item = this.itemForRoiNumber(this.contourSequence, number, 'ReferencedROINumber');
            out = this.addFieldsToOutput(out, this.contourSequence, item);
            
            out = rmfield(out, 'ReferencedROINumber');
        end
        
        function out = dicomHeaderForRoiName(this, name)    
            %loop over the structureSetSequence to find the number for the wanted name
            number = [];
            items = fieldnames(this.structureSetSequence);
            for i = 1:length(items)
                item = items{i};
                if strcmp(this.structureSetSequence.(item).ROIName, name)
                    number = this.structureSetSequence.(item).ROINumber;
                    break;
                end
            end
            %use the dataForRoiNumber to get the data for the selected name
            out = this.dicomHeaderForRoiNumber(number);
        end
        
        function item = itemForRoiNumber(~, sequence, number, fieldName)
            items = fieldnames(sequence);
            for i = 1:length(items)
                item = items{i};
                if sequence.(item).(fieldName) == number
                    return;
                end
            end
            item = [];
        end
        
        function out = addFieldsToOutput(~, out, structArray, item)
            fields = fieldnames(structArray.(item));
            for i = 1:length(fields)
                out.(fields{i}) = structArray.(item).(fields{i});
            end
        end
        
        function out = get.structureSetSequence(this)
            out = this.dicomHeader.StructureSetROISequence;
        end
        
        function out = get.observationSequence(this)
            out = this.dicomHeader.RTROIObservationsSequence;
        end
        
        function out = get.contourSequence(this)
            out = this.dicomHeader.ROIContourSequence;
        end
        
        function out = get.contourNames(this)
            items = fieldnames(this.structureSetSequence);
            out = cell(length(items), 1);
            for i = 1:length(items)
                out{i} = this.structureSetSequence.(items{i}).ROIName;
            end
        end
        
        function out = get.referencedImageSeriesUid(this)
            out = [];
            if isfield(this.dicomHeader, 'ReferencedFrameOfReferenceSequence')
                referencedFrameOfReferenceSequence = this.dicomHeader.ReferencedFrameOfReferenceSequence.Item_1;
                if isfield(referencedFrameOfReferenceSequence, 'RTReferencedStudySequence')
                    studySequence = referencedFrameOfReferenceSequence.RTReferencedStudySequence.Item_1;
                    if isfield(studySequence, 'RTReferencedSeriesSequence')
                        rtReferenceSeriesSequence = studySequence.RTReferencedSeriesSequence.Item_1;
                        if isfield(rtReferenceSeriesSequence, 'SeriesInstanceUID')
                            out = rtReferenceSeriesSequence.SeriesInstanceUID;
                        end
                    end
                end
            end
        end
        
%         function out = get.referencedFirstImageUid(this)
%             out = [];
%             if isfield(this.dicomHeader, 'ReferencedFrameOfReferenceSequence')
%                 referencedFrameOfReferenceSequence = this.dicomHeader.ReferencedFrameOfReferenceSequence.Item_1;
%                 if isfield(referencedFrameOfReferenceSequence, 'RTReferencedStudySequence')
%                     studySequence = referencedFrameOfReferenceSequence.RTReferencedStudySequence.Item_1;
%                     if isfield(studySequence, 'RTReferencedSeriesSequence')
%                         rtReferenceSeriesSequence = studySequence.RTReferencedSeriesSequence.Item_1;
%                         if isfield(rtReferenceSeriesSequence, 'SeriesInstanceUID')
%                             imageSequance = rtReferenceSeriesSequence.ContourImageSequence;
%                             if isfield(imageSequance, 'ReferencedSOPInstanceUID')
%                                 out = imageSequance.Item_1.ReferencedSOPInstanceUID;
%                             end
%                         end
%                     end
%                 end
%             end
%         end
    end
end