function out = calculateDvhD(dvh, volumeLimit, volumeLimitInPercentage, dosePercentage)    
    if nargin < 4
        volumeLimitInPercentage = true;
        dosePercentage = false;
    end

    if volumeLimitInPercentage
        volumeLimit = dvh.volume*(volumeLimit/100);
    end    

    out = dvh.vDose(find(dvh.vVolume <= volumeLimit, 1,'first'));
    %take the first one because they all have the dose criteria

    if dosePercentage
        out = out / dvh.prescribedDose * 100;
    end
end