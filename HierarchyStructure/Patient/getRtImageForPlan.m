function rtimage = getRtImageForPlan(patient, planUid)
%GETRTIMAGEFORPLAN [please add info on me here :<]
    if ~patient.planReferenceObjects.rtimageForPlan.isKey(planUid)
        rtimage = [];
        return;
    end
    list = patient.planReferenceObjects.rtimageForPlan(planUid);
    rtimage = RtImage();
    for i = 1:length(list)
        rtimage(i) = createModalityObj(patient.getDicomObject(list(i).sopInstanceUid));
    end
end