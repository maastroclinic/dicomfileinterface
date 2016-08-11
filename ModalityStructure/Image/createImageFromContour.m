function [out] = createImageFromContour( contour, pixelSpacingX, pixelSpacingY, pixelSpacingZ)   
    rows = round((contour.upperZ - contour.lowerZ)/pixelSpacingZ) + 1;
    columns = round((contour.upperX - contour.lowerX)/pixelSpacingX) + 1;
    
    out = Image();
    out.pixelSpacingX = pixelSpacingX;
    out.pixelSpacingY = pixelSpacingY;
    out.pixelSpacingZ = pixelSpacingZ;
    out.realX = (contour.lowerX+0.5*pixelSpacingX:pixelSpacingX:contour.lowerX+0.5*pixelSpacingX+(columns-1)*pixelSpacingX)';
    out.realY = [contour.uniqueY(1) - pixelSpacingY ; contour.uniqueY; contour.uniqueY(end) + pixelSpacingY]; %needed for adding empty slices
    out.realZ = (contour.lowerZ+0.5*pixelSpacingZ:pixelSpacingZ:contour.lowerZ+0.5*pixelSpacingZ+(rows-1)*pixelSpacingZ)';
    out = VolumeOfInterest(out);
end

