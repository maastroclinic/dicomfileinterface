function rtdose = getRtDoseForPlan(patient, planUid)
    if ~patient.rtdoseForPlan.isKey(planUid)
        rtdose = [];
        return;
    end
    list = patient.rtdoseForPlan(planUid);
    rtdose = RtDose();
    for i = 1:length(list)
        rtdose(i) = patient.getDicomModalityObject(list(i).sopInstanceUid);
    end
end