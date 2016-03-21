%IN: roiDose   | RoiDose | custom made matlab object
%    doseLimit | Double | in Gy
%    absolute  | Bool   | true/false
%OUT: vParam   | Double | value in cc or %
function [ vParam ] = calculateDvhV(roiDose, doseLimit, absolute)
    vParam = NaN;
    
    try 
        if absolute
            vParam = roiDose.volumeWithDoseOf(doseLimit);
        else
            vParam = roiDose.volumePercentageWithDoseOf(doseLimit);
        end
    catch EM
        warning('calculateDvhV:calculationError', EM.message)
    end
end

