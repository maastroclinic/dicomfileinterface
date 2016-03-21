%IN:  roiObj | RoiDose/RoiImage | custom matlab object that is serializable by matlab
%OUT: path   | String           | fullfile path to create serialized object
function [ path ] = createMatlabSerializedRoiObj(roiObj,inputPath)
    roiObj = roiObj.compress();
    if ~isempty(inputPath)
        if exist(inputPath, 'dir')
            path = inputPath;
        else
            path = cd;
        end
    else
        path = cd;
    end
    path = fullfile(path, [matlab.lang.makeValidName(roiObj.name) '.mat']);
    save(path, 'roiObj');
end

