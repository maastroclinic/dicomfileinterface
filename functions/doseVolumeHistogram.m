function [DVHVolumeVect, DVHDoseVect] = doseVolumeHistogram( doseCube, pixelSpacing, binSize, relative )

    doseMatrix = doseCube(~isnan(doseCube));
    doseVect = sort([0; doseMatrix(:)], 'ascend');
    DVHDoseVect   = (0:binSize:max(max(max(doseCube)))+binSize);
    DVHVolumeVect = zeros(length(DVHDoseVect),1);

    for i = 1 : length(DVHDoseVect)
        tmp              = find(doseVect >= DVHDoseVect(i));
        DVHVolumeVect(i) = (length(tmp)*prod(pixelSpacing));
    end
    
    if relative
        DVHVolumeVect = (DVHVolumeVect /(me.volume))*100;
    end

end

