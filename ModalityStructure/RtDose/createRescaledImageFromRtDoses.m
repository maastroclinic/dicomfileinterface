function out = createRescaledImageFromRtDoses(rtDoses, refImage)
%CREATERESCALEDIMAGEFROMRTDOSES creates image from an array of rtDose objects.
%
% image = createImageFromRtDose(rtdose)
%
% See also: RTDOSE, IMAGE
if ~frameOfReferenceUidIsEqual(rtDoses)
    warning('cannot add doses that where not based on the same CT scan');
    out = Image();
    return;
end

newPixelData = 0;
for i = 1:length(rtDoses)
    rtDose = rtDoses(i);
    doseImage = createImageFromRtDose(rtDose);
    matchedRtDose = matchImageRepresentation(doseImage, refImage);
    newPixelData = newPixelData + matchedRtDose.pixelData;
end

out = Image(refImage.pixelSpacingX, ...
    refImage.pixelSpacingY, ...
    refImage.pixelSpacingZ, ...
    refImage.realX, ...
    refImage.realY, ...
    refImage.realZ, ...
    newPixelData);
end

function out = frameOfReferenceUidIsEqual(rtDoses)
    out = true;
    refUid = rtDoses(1).frameOfReferenceUid;
    for i = 2:length(rtDoses)
        if ~strcmp(refUid, rtDoses(i).frameOfReferenceUid)
            out = false;
            return;
        end
    end
end