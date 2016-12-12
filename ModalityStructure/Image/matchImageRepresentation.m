function image = matchImageRepresentation(image, refImage, defaultValue, method)
%MATCHIMAGEREPRESENTATION applies a interpolation method to resample an image onto the grid of a
%reference image
%
% image = matchImageRepresentation(image, refImage) assumes a linear interpolation with a default
%  value of 0 for empty voxels
%
% image = matchImageRepresentation(image, refImage, defaultValue) use to set a different default
%  value. Warning! The funtion does not check if defaultValue is valid.
%
% image = matchImageRepresentation(image, refImage, defaultValue, method) use to set a different
%  default value and interpolation method. Warning! The funtion does not check if interpolation method is valid.
%
% See alse: IMAGE, VOLUMEOFINTEREST

    if nargin < 3
        defaultValue = double(0);
    end
    
    if nargin < 4
        method = 'linear';
    end
    
%     if ~coordinatesInRange(image, refImage)
%         image = Image();
%         return;
%     end

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

function out = coordinatesInRange(image, refImage)    
    xIsInRange = (image.realX(1) >= refImage.realX(1)) && (image.realX(end) <= refImage.realX(end));
    zIsInRange = (image.realZ(1) >= refImage.realZ(1)) && (image.realZ(end) <= refImage.realZ(end));
    
    out = xIsInRange && zIsInRange;
    
    if out == false
        warning(['The image is not within the specified reference image coordinate range' 10 ...
            'newX = ' sprintf('%5.2f', image.realX(1)) ',' sprintf('%5.2f', image.realX(end)) ', refX = ' sprintf('%5.2f', refImage.realX(1)) ',' sprintf('%5.2f', refImage.realX(end)) 10 ...
            'newZ = ' sprintf('%5.2f', image.realZ(1)) ',' sprintf('%5.2f', image.realZ(end)) ', refZ = ' sprintf('%5.2f', refImage.realZ(1)) ',' sprintf('%5.2f', refImage.realZ(end))]);
    end
end