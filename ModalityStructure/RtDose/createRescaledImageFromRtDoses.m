function out = createRescaledImageFromRtDoses(rtDoses, refImage)
%CREATERESCALEDIMAGEFROMRTDOSES creates rescaled image from an array of rtDose objects.
%
% image = createImageFromRtDose(rtDoses, refImage) creates a new image object for each RTDOSE
%   in the RtDose array on the refence spacing refImage and sums the pixelData
%
% See also: RTDOSE, IMAGE, CREATEIMAGEFROMRTDOSE
if ~frameOfReferenceUidIsEqual(rtDoses)
    warning('cannot add doses that where not based on the same CT scan');
    out = Image();
    return;
end

newPixelData = 0;
for i = 1:length(rtDoses)
    rtDose = rtDoses(i);
    doseImage = createImageFromRtDose(rtDose);
    refDoseImage = matchImageRepresentation(doseImage, refImage);
    newPixelData = newPixelData + refDoseImage.pixelData;
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