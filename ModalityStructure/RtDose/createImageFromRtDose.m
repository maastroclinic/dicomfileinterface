function image = createImageFromRtDose(rtdose)
    if ~isequal(rtdose.imageOrientationPatient,...
            [1;0;0;0;1;0]);
        throw(MException('MATLAB:createImageFromCt', 'Unsupported ImagePostionPatient for provided rtdose'));
    end
    
    if isempty(rtdose.pixelData)
        rtdose = rtdose.readDicomData();
    end
    [realX,realY,realZ] = determineDoseVectors(rtdose, 0);
    ySpacing = abs(realY(1) - realY(2));
    image = Image(rtdose.pixelSpacing(1), ySpacing, rtdose.pixelSpacing(2), realX, realY, realZ, squeeze(rtdose.scaledImageData));
end

