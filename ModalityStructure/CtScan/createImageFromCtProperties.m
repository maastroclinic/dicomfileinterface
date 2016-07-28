function image = createImageFromCtProperties(ctProperties)
    validateCtProperties(ctProperties);
    ctProperties.ImagePositionPatient(1) = ...
        convertToDouble(ctProperties.ImagePositionPatient(1));
    ctProperties.ImagePositionPatient(2) = ...
        convertToDouble(ctProperties.ImagePositionPatient(2));
    ctProperties.ImagePositionPatient(3) = ...
        convertToDouble(ctProperties.ImagePositionPatient(3));
    ctProperties.PixelSpacing(1) = ...
        convertToDouble(ctProperties.PixelSpacing(1));
    ctProperties.PixelSpacing(2) = ...
        convertToDouble(ctProperties.PixelSpacing(2));
    ctProperties.SliceThickness = ...
        convertToDouble(ctProperties.SliceThickness);
    ctProperties.Rows = ...
        convertToDouble(ctProperties.Rows);
    ctProperties.Columns = ...
        convertToDouble(ctProperties.Columns);
    ctProperties.CTFileLength = ...
        convertToDouble(ctProperties.CTFileLength);
        

    IEC_MM_TO_CM = 10;
    image = [];

    originX = [];
    originY = ctProperties.ImagePositionPatient(3)/IEC_MM_TO_CM;
    originZ = [];

    image.pixelSpacingX = ctProperties.PixelSpacing(1)/IEC_MM_TO_CM;
    image.pixelSpacingY = ctProperties.SliceThickness/IEC_MM_TO_CM;
    image.pixelSpacingZ = ctProperties.PixelSpacing(2)/IEC_MM_TO_CM;
    imagePositionPatientX = ctProperties.ImagePositionPatient(1)/IEC_MM_TO_CM;
    imagePositionPatientZ = ctProperties.ImagePositionPatient(2)/IEC_MM_TO_CM;

    if ctProperties.ImageOrientationPatient(1) == 1
        originX = imagePositionPatientX;
    elseif ctProperties.ImageOrientationPatient(1) == -1
        originX = imagePositionPatientX - ...
            (image.pixelSpacingX * ctProperties.Columns);
    end
    if ctProperties.ImageOrientationPatient(5) == -1
        originZ = -imagePositionPatientZ;
    elseif ctProperties.ImageOrientationPatient(5) == 1
        originZ = -imagePositionPatientZ - ...
            (image.pixelSpacingZ * (ctProperties.Rows - 1));
    end


    %out = (this.originX : this.pixelSpacingX : (this.originX + (this.ctSlices(1).columns - 1) * this.pixelSpacingX))';
    image.realX = (originX : image.pixelSpacingX : ...
        (originX + ...
        (double(ctProperties.Columns) - 1) * image.pixelSpacingX))';
    image.realY = (originY : image.pixelSpacingY : ...
        (originY + ...
        (ctProperties.CTFileLength - 1) * image.pixelSpacingY))';
    image.realZ = (originZ : image.pixelSpacingZ : ...
        (originZ + ...
        (ctProperties.Rows - 1) * image.pixelSpacingZ))';
    image.is3d = 1;
    end

    function doubleNumber = convertToDouble(number)
    if(~isa(number,'double'))
        doubleNumber = double(number);
    else
        doubleNumber = number;
    end
end

function validateCtProperties(ctProperties)
    if ~isfield(ctProperties,'ImagePositionPatient')
        EM = MException('CtProperties:MissingParamater', ...
            'A CT property was not specified.');
        throw(EM);
    end
    if ~(size(ctProperties.ImagePositionPatient,2) == 3)
        EM = MException('CtProperties:MissingParamater', ...
            'A CT property was not specified.');
        throw(EM);
    end
    if ~isfield(ctProperties,'PixelSpacing')
        EM = MException('CtProperties:MissingParamater', ...
            'A CT property was not specified.');
        throw(EM);
    end
    if ~(size(ctProperties.PixelSpacing,2) == 2)
       EM = MException('CtProperties:MissingParamater', ...
        'A CT property was not specified.');
       throw(EM);
    end
    if ~isfield(ctProperties,'ImageOrientationPatient')
        EM = MException('CtProperties:MissingParamater', ...
            'A CT property was not specified.');
        throw(EM);
    end
    if ~(size(ctProperties.ImageOrientationPatient,2) == 6)
        EM = MException('CtProperties:MissingParamater', ...
            'A CT property was not specified.');
        throw(EM);
    end
    if ~isfield(ctProperties,'SliceThickness')
        EM = MException('CtProperties:MissingParamater', ...
            'A CT property was not specified.');
        throw(EM);
    end
    if ~isfield(ctProperties,'Rows')
        EM = MException('CtProperties:MissingParamater', ...
            'A CT property was not specified.');
        throw(EM);
    end
    if ~isfield(ctProperties,'Columns')
        EM = MException('CtProperties:MissingParamater', ...
            'A CT property was not specified.');
        throw(EM);
    end
end