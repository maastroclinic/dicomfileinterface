%IN: roiDose                | RoiDose| custom made matlab object
%    volumeLimit            | Double | in cc or %
%    volumeType             | String | cc or %
%    targetPrescriptionDose | Double | in Gy
%    absolute               | Bool   | true/false (output in Gy or %)
%OUT: vParam   | Double | value in cc or %
function [ dParam ] = calculateDvhD(roiDose, volumeLimit, volumeType, targetPrescriptionDose, absolute)
    dParam = NaN;
    
    if ~absolute && isempty(targetPrescriptionDose)
        warning('calculateDvhD:WrongParameter', 'd-params in %% require a target prescription dose!');
        return;
    end
    
    if ~strcmp('cc', volumeType) && ~strcmp('%', volumeType)
        warning('calculateDvhD:WrongParameter', 'input type needs to be cc or %%');
        return;
    end
    
    try         
        if strcmp('cc', volumeType) && absolute
            dParam = roiDose.doseToCertainVolume(volumeLimit);
            
        elseif strcmp('cc', volumeType) && ~ absolute
            dParam = roiDose.dosePercentageToCertainVolume(volumeLimit, targetPrescriptionDose);
        
        elseif strcmp('%', volumeType) && absolute
            dParam = roiDose.doseToCertainVolumePercentage(volumeLimit);
        
        else
            dParam = roiDose.dosePercentageToCertainVolumePercentage(volumeLimit, targetPrescriptionDose); 
        end
    catch EM
        warning('calculateDvhV:calculationError', EM.message)
    end
end

