%IN:  roiObj   | RoiDose/RoiVolume | custom data object for this project
%OUT: volume   | Double            | value in cc 
function [ volume ] = calculateVolume(roiObj)
    
    volume = NaN;
    
    try 
        volume = roiObj.volume();
    catch EM
        warning('calculateDose:unknownError', EM.message);
    end
        
end


