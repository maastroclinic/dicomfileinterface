function rtstruct = getRtStructForPlan(patient, planUid)
    if ~patient.rtstructsForPlan.isKey(planUid)
        rtstruct = [];
        return;
    end
    rtstruct = patient.getDicomModalityObject(patient.rtstructsForPlan(planUid));
end