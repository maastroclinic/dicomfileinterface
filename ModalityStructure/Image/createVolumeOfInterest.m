function image = createVolumeOfInterest(contour, refImage)
%CREATEBITMASK for a contour object on a referenced image grid
    if ~refImage.is3d
        image = Image();
        warning('function is made for 3d interpolation, could not project contour on image')
        return;
    end
    
    if contour.numberOfContourSlices == 0
        image = Image();
        warning('provided contour is not a valid contour, no contourSlices found in object')
        return;
    end
    
    image = createImageFromContour(contour, refImage.pixelSpacingX, refImage.pixelSpacingY, refImage.pixelSpacingZ);

    iY = contour.indexUniqueY;
    pixelData = zeros(image.columns,image.rows,image.slices);
    for i = 1 : contour.numberOfContourSlices
        pixelData(:,:,iY(i)+1) = pixelData(:,:,iY(i)+1) + poly2mask( ...
            (contour.contourSlices(i).z - contour.lowerZ) / refImage.pixelSpacingZ + 0.5 , ...
            (contour.contourSlices(i).x - contour.lowerX) / refImage.pixelSpacingX + 0.5, ...
            image.columns,image.rows);
    end
    pixelData(pixelData > 1) = 1;
    image = image.addPixelData((permute(pixelData,[1 3 2])), false);
    
    if image.is3d
        image = matchImageRepresentation(image, refImage);
    else
        throw(MException('MATLAB:createImageBitmask', 'contour object does not contain a valid 3d contour'));
    end
end