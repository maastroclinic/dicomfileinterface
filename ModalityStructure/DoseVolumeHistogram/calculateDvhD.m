function out = calculateDvhD(dvh, volumeLimit, volumeLimitInPercentage, dosePercentage)    
%CALCULATEDVHD uses a DoseVolumeHistogram to calculate a wanted DVH-D parameter in Gy/Percentage
%
% out = calculateDvhD(dvh, volumeLimit) is the simple calculation where the volumeLimit is 
%  assumed to be in percentage.
%
% out = calculateDvhD(dvh, volumeLimit, volumeLimitInPercentage, dosePercentage) providing more
%  inputs will enable an absolute volumeLimit and an dose output in percentage
%
% See also: DOSEVOLUMEHISTOGRAM, CALCULATEDVHV
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