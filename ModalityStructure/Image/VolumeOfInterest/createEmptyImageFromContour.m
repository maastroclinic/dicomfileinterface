function voi = createEmptyImageFromContour(contour, pixelSpacingX, pixelSpacingY, pixelSpacingZ)   
%CREATEEMPTYIMAGEFROMCONTOUR creates an VolumeOfInterest object using the data in Contour and
% prefered pixel spacing
%
% voi = createImageFromContour(contour, pixelSpacingX, pixelSpacingY, pixelSpacingZ)
%  this is a helper function for createVolumeOfInterest.
%
% See also: CREATEVOLUMEOFINTEREST, CONTOUR, IMAGE, VOLUMEOFINTEREST
    rows = round((contour.upperZ - contour.lowerZ)/pixelSpacingZ) + 1;
    columns = round((contour.upperX - contour.lowerX)/pixelSpacingX) + 1;
    
    image = Image();
    image.pixelSpacingX = pixelSpacingX;
    image.pixelSpacingY = pixelSpacingY;
    image.pixelSpacingZ = pixelSpacingZ;
    image.realX = (contour.lowerX+0.5*pixelSpacingX:pixelSpacingX:contour.lowerX+0.5*pixelSpacingX+(columns-1)*pixelSpacingX)';
    image.realY = [contour.uniqueY(1) - pixelSpacingY ; contour.uniqueY; contour.uniqueY(end) + pixelSpacingY]; %needed for adding empty slices
    image.realZ = (contour.lowerZ+0.5*pixelSpacingZ:pixelSpacingZ:contour.lowerZ+0.5*pixelSpacingZ+(rows-1)*pixelSpacingZ)';
    voi = VolumeOfInterest(image);
end

