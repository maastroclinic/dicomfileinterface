function rtdose = getRtDoseForPlan(patient, planUid)
    if ~patient.planReferenceObjects.rtdoseForPlan.isKey(planUid)
        rtdose = [];
        return;
    end
    list = patient.planReferenceObjects.rtdoseForPlan(planUid);
    rtdose = RtDose();
    j = 1;
    for i = 1:length(list)
        tmpDose = createModalityObj(patient.getDicomObject(list(i).sopInstanceUid));
        if strcmp('plan',tmpDose.doseSummationType)
            rtdose(j) = tmpDose;
            j = j + 1;
        end
    end
end