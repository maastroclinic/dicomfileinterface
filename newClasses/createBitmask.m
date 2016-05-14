function out = createBitmask(contourObj, image)
%CREATEBITMASK for a contour object on a referenced image grid
    
    columns = round((contourObj.upperX - contourObj.lowerX)/image.pixelSpacingX) + 1;
    slices = round((contourObj.upperY - contourObj.lowerY)/image.pixelSpacingY) + 1;
    rows = round((contourObj.upperZ - contourObj.lowerZ)/image.pixelSpacingZ) + 1;
    
%   TODO Left this here because DGRT does this, this might be the reason why the code fails when having
%   multiple stand alone delineations in one contour, use Erik's test case to verify this later.
%     [Y,~,J] = unique(YPos); 
    unscaledBitmask = zeros(columns,rows,slices);
    for n = 1 : slices,
        unscaledBitmask(:,:,n) = unscaledBitmask(:,:,n) + poly2mask( ...
            (contourObj.contourSlices(n).z - contourObj.lowerZ) / image.pixelSpacingZ + 0.5 , ...
            (contourObj.contourSlices(n).x - contourObj.lowerX) / image.pixelSpacingX + 0.5, ...
            columns,rows);
    end
    unscaledBitmask(unscaledBitmask > 1) = 1;
    unscaledBitmask = permute(unscaledBitmask,[1 3 2]);

    % define X/Y/Z vectors of original and new 3D grid
    contourRealX = (contourObj.lowerX+0.5*image.pixelSpacingX:image.pixelSpacingX:contourObj.lowerX+0.5*image.pixelSpacingX+(columns-1)*image.pixelSpacingX)';
    contourRealY = contourObj.y';
    contourRealZ = (contourObj.lowerZ+0.5*image.pixelSpacingZ:image.pixelSpacingZ:contourObj.lowerZ+0.5*image.pixelSpacingZ+(rows-1)*image.pixelSpacingZ)';

    if length(contourRealX) > 1 && length(contourRealY) > 1 && length(contourRealZ) > 1
        % re-sample 3D volume
        mask = VolumeResample(unscaledBitmask,contourRealX,contourRealY,contourRealZ,image.realX,image.realY,image.realZ);
        mask (mask >= 0.5) = 1;
        mask (mask < 0.5) = 0;
        out = VolumeOfInterest(image);
        out = out.addImageData(mask);
    else
        throw(MException('MATLAB:createBitmask', ['No 3D delineation found, [x, y, z]: ' ...
            num2str(length(contourRealX)) ',' num2str(length(contourRealY)) ',' num2str(length(contourRealZ))]));
    end
end