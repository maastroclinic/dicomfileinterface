function out = createBitmask(contourObj, image)
%CREATEBITMASK for a contour object on a referenced image grid
    
    columns = round((contourObj.upperX - contourObj.lowerX)/image.pixelSpacingX) + 1;
    slices = round((contourObj.upperY - contourObj.lowerY)/image.pixelSpacingY) + 1;
    rows = round((contourObj.upperZ - contourObj.lowerZ)/image.pixelSpacingZ) + 1;
    
%     [Y,~,J] = unique(YPos);
    structureData = zeros(columns,rows,slices);
    for n = 1 : slices,
        structureData(:,:,n) = structureData(:,:,n) + poly2mask( ...
            (contourObj.contourSlices(n).z - contourObj.lowerZ) / image.pixelSpacingZ + 0.5 , ...
            (contourObj.contourSlices(n).x - contourObj.lowerX) / image.pixelSpacingX + 0.5, ...
            columns,rows);
    end
    structureData(structureData > 1) = 1;
    structureData = permute(structureData,[1 3 2]);

    % define X/Y/Z vectors of original and new 3D grid
    XStruct = (contourObj.lowerX+0.5*image.pixelSpacingX:image.pixelSpacingX:contourObj.lowerX+0.5*image.pixelSpacingX+(columns-1)*image.pixelSpacingX)';
    YStruct = contourObj.y';
    ZStruct = (contourObj.lowerZ+0.5*image.pixelSpacingZ:image.pixelSpacingZ:contourObj.lowerZ+0.5*image.pixelSpacingZ+(rows-1)*image.pixelSpacingZ)';

    if length(XStruct) > 1 && length(YStruct) > 1 && length(ZStruct) > 1
        % re-sample 3D volume
        out = VolumeResample(structureData,XStruct,YStruct,ZStruct,image.realX,image.realY,image.realZ);
        out (out >= 0.5) = 1;
        out (out < 0.5) = 0;
    else
        throw(MException('MATLAB:createBitmask', ['No 3D delineation found, [x, y, z]: ' ...
            num2str(length(XStruct)) ',' num2str(length(YStruct)) ',' num2str(length(ZStruct))]));
    end
end