function rtdose = getRtDoseForPlan(patient, planUid)
    if ~patient.planReferenceObjects.rtdoseForPlan.isKey(planUid)
        rtdose = [];
        return;
    end
    list = patient.planReferenceObjects.rtdoseForPlan(planUid);
    rtdose = RtDose();
    for i = 1:length(list)
        rtdose(i) = createModalityObj(patient.getDicomObject(list(i).sopInstanceUid));
    end
end