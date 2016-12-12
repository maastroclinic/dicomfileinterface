function rtstruct = getRtStructForPlan(patient, planUid)
%GETRTSTRUCTFORPLAN [please add info on me here :<]
    if ~patient.planReferenceObjects.rtstructsForPlan.isKey(planUid)
        rtstruct = [];
        return;
    end
    rtstruct = patient.getDicomObject(patient.planReferenceObjects.rtstructsForPlan(planUid));
    rtstruct = createModalityObj(rtstruct);
end