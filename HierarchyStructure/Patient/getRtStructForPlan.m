function rtstruct = getRtStructForPlan(patient, planUid)
    if ~patient.planReferenceObjects.rtstructsForPlan.isKey(planUid)
        rtstruct = [];
        return;
    end
    rtstruct = patient.getDicomObject(patient.planReferenceObjects.rtstructsForPlan(planUid));
    rtstruct = createModalityObj(rtstruct);
end