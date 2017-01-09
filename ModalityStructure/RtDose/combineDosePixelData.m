function [binData, sumDoseGridScaling] = combineDosePixelData(rtDoses)
%COMBINEDOSEPIXELDATA creates new pixelData combining the list of RtDose files
%
% [binData, sumDoseGridScaling] = combineDosePixelData(rtDoses) combines the pixel data
%   of RtDose files which are based on the same dose grid. binData is a uint16 matrix that can be 
%   converted to dose in [Gy] by using the doseGridScaling factor. these values can be used to write
%   a new combined RtDose file.
%
% See also: RTDOSE, DICOMOBJ, DICOMOBJ.WRITETOFILE
    if ~doseGridsAreEqual(rtDoses)
        throw(MException('MATLAB:createDoseSeriesForCombinablePlans:DimensionError', 'the RTDOSES associated with the RTPLANS are not combinable because of a dimension mismatch'));
    end

    sumImage = zeros(rtDoses(1).rows,rtDoses(1).columns,1,rtDoses(1).numberOfFrames);
    sumDoseGridScaling = 0;
    for i = 1:length(rtDoses)
        pixelData = dicomread(rtDoses(i).filename);
        sumImage = sumImage + double(pixelData).*rtDoses(i).doseGridScaling;
        sumDoseGridScaling = sumDoseGridScaling + rtDoses(i).doseGridScaling;
    end
    binData = uint16(sumImage./sumDoseGridScaling);
end


function out = doseGridsAreEqual(dose)
    out = true;
    if ~isequal(dose.frameOfReferenceUid) || ...
            ~isequal(dose.originX) || ...
            ~isequal(dose.originY) || ...
            ~isequal(dose.originZ) || ...
            ~isequal(dose.imageOrientationPatient) || ...
            ~isequal(dose.imagePositionPatient)
        out = false;
    end
end
