function dvh = createDoseVolumeHistogramFromDto( dvhDto )
%CREATEDOSEVOLUMEHISTOGRAMFROMDTO is a function to convert the DoseVolumeHistogram JSON DTO
% object to the matlab DOSEVOLUMEHISTOGRAM. This is used for REST communication.
%
% dto = createDoseVolumeHistogramFromDto(dvhDto)
%
% See also: DOSEVOLUMEHISTOGRAM, CREATEDOSEVOLUMEHISTOGRAMDTO
    dvh = DoseVolumeHistogram();
    dvhStruct = loadjson(dvhDto);
    
    dvh.volume = dvhStruct.volume;
    dvh.minDose = dvhStruct.minDose;
    dvh.meanDose = dvhStruct.meanDose;
    dvh.maxDose = dvhStruct.maxDose;
    dvh.vVolume = dvhStruct.vVolume;
    dvh.vDose = dvhStruct.vDose;
end

