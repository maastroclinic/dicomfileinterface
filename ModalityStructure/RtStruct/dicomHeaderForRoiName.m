function out = dicomHeaderForRoiName(rtStruct, name)
    number = [];
    items = fieldnames(rtStruct.structureSetSequence);
    for i = 1:length(items)
        item = items{i};
        if strcmp(rtStruct.structureSetSequence.(item).ROIName, name)
            number = rtStruct.structureSetSequence.(item).ROINumber;
            break;
        end
    end
    out = dicomHeaderForRoiNumber(rtStruct, number);
end

