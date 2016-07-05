function [plan, dose, struct, ct] = createPlanPackage(patient, planLabel)
    planUid = patient.planReferenceObjects.getPlanUidForLabel(planLabel);
    if isempty(planUid)
        throw(MException('MATLAB:Patient:createPlanPackage', 'planLabel not found for patient'))
    end            
    plan = createModalityObj(patient.getDicomObject(planUid));
    dose = getRtDoseForPlan(patient, planUid);
    struct = getRtStructForPlan(patient, planUid);
    ct = getCtScanForPlan(patient, planUid);
end