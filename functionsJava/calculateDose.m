%IN:  roiDose   | RoiDose | custom made matlab object
%     operation | String  | min / mean / max
%OUT: dose      | Double  | dose in Gy
function [ dose ] = calculateDose(roiDose, operation)
    dose = NaN;
    
    if ~roiDose.hasFittedRoiValues
        warning('matlabCalcualtions:MissingParamater', 'Missing fitted RTDOSE file');
        return;
    end

    try 
        dose = roiDose.dose(operation);
    catch EM
        warning('calculateDose:unknownError', EM.message);
    end  
end

