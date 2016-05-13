function image = createImageFromCt( ctScan, loadImageData)
%CREATEIMAGEFROMCT 
    image = Image();
    
    if ~ctScan.hasUniformThickness()
        throw(MException());
    end
    
    if ~ctScan.hasUniformPixelSpacing()
        throw(MException());
    end
    
    imageOrientationPatient = ctScan.sortedCtSlices(1).imageOrientationPatient;
    if ~isequal(imageOrientationPatient,...
                [1;0;0;0;1;0]);
        % Note: explicit conversion from logical to unint16 to
        % make this strange calculation possible, otherwise it
        % would error out with the following error:
        % Error using  .*
        % Integers can only be combined with integers of the
        % same class, or scalar doubles.
        throw(MException(':', ''));
    end
    
    pixelSpacingX = double(ctScan.pixelSpacing(1)) /10; %conversion to CM, stored in mm in DICOM
    pixelSpacingY = double(ctScan.sliceThickness)  /10; 
    pixelSpacingZ = double(ctScan.pixelSpacing(1)) /10;
    
    dimensionX = double(ctScan.sortedCtSlices(1).rows); 
    dimensionY = double(ctScan.numberOfSlices);
    dimensionZ = double(ctScan.sortedCtSlices(1).columns);

    %TODO do not understand this voodoo yet...
    originX = (imageOrientationPatient(1)/10) - ...
                (uint16(imageOrientationPatient) == -1) * ...
                (pixelSpacingX * dimensionX);
    originY = (imageOrientationPatient(3) / 10);
    originZ = (-imageOrientationPatient(2) / 10) - ...
                double(imageOrientationPatient(5)) * ...
                (pixelSpacingZ * dimensionZ - 1);


    realX = (originX:pixelSpacingX:originX + (dimensionX - 1) * pixelSpacingX)';
    realY = (originY:pixelSpacingY:originY + (dimensionY - 1) * pixelSpacingY)';
    realZ = (originZ:pixelSpacingZ:originZ + (dimensionZ - 1) * pixelSpacingZ)';
    
    if loadImageData
        %TODO, add transformation;
    else
        image = Image(pixelSpacingX, pixelSpacingY, pixelSpacingZ, realX, realY, realZ, []);
    end
end

