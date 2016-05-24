function out = createBitmask(contourObj, image)
%CREATEBITMASK for a contour object on a referenced image grid
    
    columns = round((contourObj.upperX - contourObj.lowerX)/image.pixelSpacingX) + 1;
    slices = contourObj.numberOfCtSlices;
    rows = round((contourObj.upperZ - contourObj.lowerZ)/image.pixelSpacingZ) + 1;
    

    iY = contourObj.indexUniqueY;
    unscaledBitmask = zeros(columns,rows,slices);
    for i = 1 : contourObj.numberOfContourSlices
        unscaledBitmask(:,:,iY(i)) = unscaledBitmask(:,:,iY(i)) + poly2mask( ...
            (contourObj.contourSlices(i).z - contourObj.lowerZ) / image.pixelSpacingZ + 0.5 , ...
            (contourObj.contourSlices(i).x - contourObj.lowerX) / image.pixelSpacingX + 0.5, ...
            columns,rows);
    end
    unscaledBitmask(unscaledBitmask > 1) = 1;
    unscaledBitmask = permute(unscaledBitmask,[1 3 2]);

    % define X/Y/Z vectors of original and new 3D grid
    contourRealX = (contourObj.lowerX+0.5*image.pixelSpacingX:image.pixelSpacingX:contourObj.lowerX+0.5*image.pixelSpacingX+(columns-1)*image.pixelSpacingX)';
    contourRealY = contourObj.uniqueY';
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