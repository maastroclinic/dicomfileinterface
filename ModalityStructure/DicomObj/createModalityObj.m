function dicomObj = createModalityObj(dicomObj)
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