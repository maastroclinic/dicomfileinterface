function image = createImageBitmask(contour, refImage)
%CREATEBITMASK for a contour object on a referenced image grid
    if ~refImage.is3d
        throw(MException('MATLAB:createImageBitmask', 'function is made for 3d interpolation, please provide a 3D reference image'));
    end
    
    image = createImageFromContour(contour, refImage.pixelSpacingX, refImage.pixelSpacingY, refImage.pixelSpacingZ);

    iY = contour.indexUniqueY;
    image.pixelData = zeros(image.columns,image.rows,image.slices);
    for i = 1 : contour.numberOfContourSlices
        image.pixelData(:,:,iY(i)) = image.pixelData(:,:,iY(i)) + poly2mask( ...
            (contour.contourSlices(i).z - contour.lowerZ) / refImage.pixelSpacingZ + 0.5 , ...
            (contour.contourSlices(i).x - contour.lowerX) / refImage.pixelSpacingX + 0.5, ...
            image.columns,image.rows);
    end
    image.pixelData(image.pixelData > 1) = 1;
    image.pixelData = logical(permute(image.pixelData,[1 3 2]));

    if image.is3d
        image = matchImageRepresentation(image, refImage);
    else
        throw(MException('MATLAB:createImageBitmask', 'contour object does not contain a valid 3d contour'));
    end
end