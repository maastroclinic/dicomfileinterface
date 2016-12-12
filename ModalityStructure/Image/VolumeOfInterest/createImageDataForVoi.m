function [ voiImage ] = createImageDataForVoi(voi, image)
%CREATEIMAGEDATAFORVOI creates an image with values for a bitmask.
%
%createImageDataForVoi(voi, refImage) default mode. provide a VolumeOfInterest and an Image
% with loaded pixel data
%
% See also: VOLUMEOFINTEREST, CREATEIMAGEDATAFORVOIFULLGRID

    image = image.pixelData(voi.xCompressed, voi.yCompressed, voi.zCompressed);
    image = voi.pixelData .* image;
    image(image == 0) = NaN;

    voiImage = Image(voi.pixelSpacingX, ...
        voi.pixelSpacingY, ...
        voi.pixelSpacingZ, ...
        voi.realX(voi.xCompressed), ...
        voi.realY(voi.yCompressed), ...
        voi.realZ(voi.zCompressed), ...
        image);
end