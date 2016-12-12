function dicomObj = createModalityObj(dicomObj)
%CREATEMODALITYOBJ converts a dicomObj to the corresponding modality
%
% dicomObj = createModalityObj(dicomObj)
%
% See also: DICOMOBJ, CTSLICE, RTPLAN, RTSTRUCT, RTDOSE, RTIMAGE
    switch dicomObj.modality
        case 'ct'
            dicomObj = CtSlice(dicomObj, []);
        case 'rtplan'
            dicomObj = RtPlan(dicomObj, []);
        case 'rtstruct'
            dicomObj = RtStruct(dicomObj, []);
        case 'rtdose'
            dicomObj = RtDose(dicomObj, []);
        case 'rtimage'
            dicomObj = RtImage(dicomObj, []);
    end
end
