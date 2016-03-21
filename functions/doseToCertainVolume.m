%DVH info:
% the dose to 95% of the considered volume (D95) 
% SOURCE: http://ro-journal.biomedcentral.com/articles/10.1186/1748-717X-4-44
% volumeLimit(cc), out(Gy)
function out = doseToCertainVolume(doseCube, pixelSpacing, volumeLimit, volumeLimitPercentage, volume, dosePercentage, targetPresriptionDose)
    
    if volumeLimitPercentage
        volumeLimit = volume*(volumeLimit/100);
    end

    %max value is added 2 times at beginning, because zero is
    %added before dose vector
    doseMatrix  = doseCube(~isnan(doseCube));
    doseVect    = sort([0; doseMatrix(:)], 'ascend');
    volumeVect  = [volume, volume:-prod(pixelSpacing):prod(pixelSpacing)];
    out         = doseVect(find(volumeVect <= volumeLimit, 1,'first'));
    %take the first one because they all have the dose criteria
    
    if dosePercentage
        out = out / targetPresriptionDose * 100;
    end
end

