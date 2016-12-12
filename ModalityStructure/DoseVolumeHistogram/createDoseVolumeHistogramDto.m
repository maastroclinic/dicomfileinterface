function dto = createDoseVolumeHistogramDto(dvh)
%CREATEDOSEVOLUMEHISTOGRAMDTO is a function to convert the DoseVolumeHistogram 
% object to a JSON DTO object. This is used for REST communication.
%
% dto = createDoseVolumeHistogramDto(dvh)
%
% See also: DOSEVOLUMEHISTOGRAM, CREATEDOSEVOLUMEHISTOGRAMFROMDTO

    dvhOutput.volumeUnity = 'cc';
    dvhOutput.doseUnity = 'Gy';
    
    dvhOutput.volume = dvh.volume;
    dvhOutput.minDose = dvh.minDose;
    dvhOutput.meanDose = dvh.meanDose;
    dvhOutput.maxDose = dvh.maxDose;
    
    dvhOutput.vVolume = dvh.vVolume;
    dvhOutput.vDose = dvh.vDose;

    dto = savejson('',dvhOutput);
end