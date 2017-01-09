classdef RtStruct < DicomObj
    %RTSTRUCT Representation of a DICOM RTSTRUCT
    %
    %CONSTRUCTOR
    % this = RtStruct(dicomItem, useVrHeuristics) creates a RtStruct object
    %  using the full file path (or a DicomObj) and boolean to deterine the use of VR Heuristics
    %
    % See also: DICOMOBJ, CONTOUR, CONTOURSLICE, DICOMHEADERFORROINUMBER, DICOMHEADERFORROINAME
    
    properties
        structureSetSequence
        observationSequence
        contourSequence
        contourNames
        referencedImageSeriesUid
    end
    
    methods
        function this = RtStruct(dicomItem, useVrHeuristics)
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            
            this = constructorParser(this, 'rtstruct', dicomItem, useVrHeuristics);
        end

        function readDicomData(~)
        %READDICOMDATA is overwritten for RTSTRUCT because RTSTRUCTS do not contain pixel data, just
        % header info.
            warning('this standard dicom function is overwritten because the rtstruct dicom object does not contain an image block');
        end
                
        % -------- START GETTERS/SETTERS ----------------------------------
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
    end
end