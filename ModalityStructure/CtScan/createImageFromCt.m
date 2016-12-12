function image = createImageFromCt(ctScan, loadImageData)
% CREATEIMAGEFROMCT creates an Image object using data from the CtScan object
%
% image = CREATEIMAGEFROMCT(ctScan, loadImageData) returns an image object which represents the data
%  in the CtScan dicom object. loadImageData is a boolean to determine if the actual image data is loaded. If the image is only
%  needed to define a grid for RTSTRUCT or RTDOSE reading the image data is unnecessary and will
%  save time
%
% See also: CTSCAN, CTSLICE, CREATEIMAGEFROMCTPROPERTIES

    if ~ctScan.hasUniformThickness()
        throw(MException('MATLAB:createImageFromCt', 'CT scans with changing sliceThickness are not supported'));
    end
        
    if ~isequal(ctScan.ySortedCtSlices(1).imageOrientationPatient,...
                [1;0;0;0;1;0]);
        throw(MException('MATLAB:createImageFromCt', 'Unsupported ImagePostionPatient for provided CT scan'));
    end
    
    if loadImageData
        ctScan = ctScan.readDicomData();
    end
    image = Image(ctScan.pixelSpacingX, ctScan.pixelSpacingY, ctScan.pixelSpacingZ, ctScan.realX, ctScan.realY, ctScan.realZ, ctScan.pixelData);
end