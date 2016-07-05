function [ dto ] = createDoseVolumeHistogramDto( dvh )
    
    dvhOutput.volumeUnity = 'cc';
    dvhOutput.doseUnity = 'Gy';
    
    dvhOutput.volume = dvh.volume;
    dvhOutput.minDose = dvh.minDose;
    dvhOutput.meanDose = dvh.meanDose;
    dvhOutput.maxDose = dvh.maxDose;
    
    dvhOutput.vVolume = dvh.vVolume;
    dvhOutput.vDose = dvh.vDose;

    dto = savejson(dvhOutput);
end