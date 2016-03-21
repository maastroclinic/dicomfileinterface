%IN: binsize | Double | in Gy
%    absolute| Bool   | true/false
%OUT: vVolume| Double | vector in cc or %
%     vDose  | Double | vector in Gy
function [ vVolume, vDose ] = calculateDvhCurve(roiDose, binsize, absolute)

    vVolume = NaN;
    vDose   = NaN;
    
    try 
        if absolute
            [ vVolume, vDose ] = roiDose.exportDoseVolumeHistogramAbsolute(binsize);
        else
            [ vVolume, vDose ] = roiDose.exportDoseVolumeHistogram(binsize);
        end
    catch EM
        warning('calculateDvhCurve:calculationError', EM.message)
    end
end

