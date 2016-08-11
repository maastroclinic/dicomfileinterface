function image = matchImageRepresentation( image, refImage, defaultValue, method)
    if nargin < 3
        defaultValue = double(0);
    end
    
    if nargin < 4
        method = 'linear';
    end

    newImage = interp3(...
        double(image.realY),...
        double(image.realX),...
        double(image.realZ),...
        double(image.pixelData),...
        double(refImage.realY),...
        double(refImage.realX),...
        double(refImage.realZ)',... 
        ... %do not know why this Z should be rotated but the calculation won't work otherwise
        method,defaultValue);
    
    image.realX = refImage.realX;
    image.realY = refImage.realY;
    image.realZ = refImage.realZ;
    image.pixelSpacingX = refImage.pixelSpacingX;
    image.pixelSpacingY = refImage.pixelSpacingY;
    image.pixelSpacingZ = refImage.pixelSpacingZ;

    if isa(image,'VolumeOfInterest')
        newImage(newImage >= 0.5) = 1;
        newImage(newImage < 0.5) = 0;
        image = image.addPixelData(newImage);
    else
        image = image.addPixelData(newImage);
    end
end

