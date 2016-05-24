function [plan, dose, struct, ct] = createPlanPackage(this, planLabel)
    planUid = this.getPlanUidForLabel(planLabel);
    if isempty(planUid)
        throw(MException('MATLAB:Patient:createPlanPackage', 'planLabel not found for patient'))
    end            
    plan = RtPlan(this.getDicomObject(planUid), []);
    dose = this.getRtDoseForPlan(planUid);
    struct = this.getRtStructForPlan(planUid);
    ct = this.getCtScanForPlan(planUid);
end