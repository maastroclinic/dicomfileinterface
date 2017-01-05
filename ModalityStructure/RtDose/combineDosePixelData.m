function [binData, sumDoseGridScaling] = combineDosePixelData(dose)
%COMBINEDOSEPIXELDATA
    if ~doseGridsAreEqual(dose)
        throw(MException('MATLAB:createDoseSeriesForCombinablePlans:DimensionError', 'the RTDOSES associated with the RTPLANS are not combinable because of a dimension mismatch'));
    end

    sumImage = zeros(dose(1).rows,dose(1).columns,1,dose(1).numberOfFrames);
    sumDoseGridScaling = 0;
    for i = 1:length(dose)
        pixelData = dicomread(dose(i).filename);
        sumImage = sumImage + double(pixelData).*dose(i).doseGridScaling;
        sumDoseGridScaling = sumDoseGridScaling + dose(i).doseGridScaling;
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
