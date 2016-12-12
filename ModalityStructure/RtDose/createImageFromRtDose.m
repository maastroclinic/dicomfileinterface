function image = createImageFromRtDose(rtdose)
%CREATEIMAGEFROMRTDOSE creates an Image object using the binary data of the RtDose file
%
% image = createImageFromRtDose(rtdose)
%
% See also: RTDOSE, DETERMINEDOSEVECTORS, IMAGE
    if ~isequal(rtdose.imageOrientationPatient,...
            [1;0;0;0;1;0]);
        warning('Unsupported ImagePostionPatient for provided rtdose');
        image =  Image();
        return;
    end
    
    if isempty(rtdose.pixelData)
        rtdose = rtdose.readDicomData();
    end
    [realX,realY,realZ] = determineDoseVectors(rtdose, 0);
    ySpacing = abs(realY(1) - realY(2));
    image = Image(rtdose.pixelSpacing(1), ySpacing, rtdose.pixelSpacing(2), realX, realY, realZ, squeeze(rtdose.scaledImageData));
end

