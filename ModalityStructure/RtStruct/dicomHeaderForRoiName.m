function out = dicomHeaderForRoiName(rtStruct, name)
%DICOMHEADERFORROINUMBER parses the rtStruct dicom header to find all relevant tags for the contour
%object using the (3006,0026) ROIName tag
%
% out = dicomHeaderForRoiName(rtStruct, name) return the dicom header when a valid name is provided
%
% See also: RTSTRUCT, CONTOUR, CONTOURSLICE, DICOMHEADERFORROINUMBER
    number = [];
    items = fieldnames(rtStruct.structureSetSequence);
    for i = 1:length(items)
        item = items{i};
        if strcmp(rtStruct.structureSetSequence.(item).ROIName, name)
            number = rtStruct.structureSetSequence.(item).ROINumber;
            break;
        end
    end
    
    if isempty(number)
        warning('ROI not found');
        out = [];
        return;
    end
    
    out = dicomHeaderForRoiNumber(rtStruct, number);
end

