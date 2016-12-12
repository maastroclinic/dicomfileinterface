function out = dicomHeaderForRoiNumber(rtStruct, number)
%DICOMHEADERFORROINUMBER parses the rtStruct dicom header to find all relevant tags for the contour
%object using the (3006,0022) ROINumber tag
%
% out = dicomHeaderForRoiNumber(rtStruct, number) returns the dicom header for the specified ROI
%  number
%
% See also: RTSTRUCT, CONTOUR, CONTOURSLICE, DICOMHEADERFORROINAME
    out = [];

    item = itemForRoiNumber(rtStruct.structureSetSequence, number, 'ROINumber');
    out = addFieldsToOutput(out, rtStruct.structureSetSequence, item);

    item = itemForRoiNumber(rtStruct.observationSequence, number, 'ReferencedROINumber');
    out = addFieldsToOutput(out, rtStruct.observationSequence, item);

    item = itemForRoiNumber(rtStruct.contourSequence, number, 'ReferencedROINumber');
    out = addFieldsToOutput(out, rtStruct.contourSequence, item);

    if ~isempty(out)
        out = rmfield(out, 'ReferencedROINumber');
    end
end

function out = addFieldsToOutput(out, structArray, item)
    if isempty(item)
        out =[];
        return;
    end

    fields = fieldnames(structArray.(item));
    for i = 1:length(fields)
        out.(fields{i}) = structArray.(item).(fields{i});
    end
end

function item = itemForRoiNumber(sequence, number, fieldName)
    items = fieldnames(sequence);
    for i = 1:length(items)
        item = items{i};
        if sequence.(item).(fieldName) == number
            return;
        end
    end
    item = [];
end
