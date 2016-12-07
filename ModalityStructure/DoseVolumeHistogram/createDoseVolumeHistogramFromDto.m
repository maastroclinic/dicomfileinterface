function dvh = createDoseVolumeHistogramFromDto( dvhDto )
    dvh = DoseVolumeHistogram();
    dvhStruct = loadjson(dvhDto);
    
    dvh.volume = dvhStruct.volume;
    dvh.minDose = dvhStruct.minDose;
    dvh.meanDose = dvhStruct.meanDose;
    dvh.maxDose = dvhStruct.maxDose;
    dvh.vVolume = dvhStruct.vVolume;
    dvh.vDose = dvhStruct.vDose;
end

