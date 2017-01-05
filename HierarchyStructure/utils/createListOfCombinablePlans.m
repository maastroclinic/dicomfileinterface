function combinablePlanUids = createListOfCombinablePlans(patient, refPlanUid)
%CREATELISTOFCOMBINABLEPLANS creates a dicomObj Array that containes the objects of two
%plans than can be combined into one because it is based on the same anatomy.
%
% combinablePlanUids = createListOfCombinablePlans(patient, refPlanUid)
%
% See also: PATIENT, COMBINEDOSEPIXELDATA, CREATEDOSESERIESFORCOMBINABLEPLANS
    [plans, refPlan] = collectPlansFromPatient(patient, refPlanUid);
    
    if isempty(refPlan)
        throw(MException('MATLAB:createListOfCombinableDosesForPlan:ObjectNotFound', ...
                          'The requested reference object is not present in the provided patient'));
    end

    combinablePlanUids{1} = refPlanUid;
    keys = plans.keys;
    if isempty(keys)
        return;
    end
    
    for i = 1:length(keys)
        plan = plans(keys{i});
        if planIsEqual(plan, refPlan)
            combinablePlanUids{end+1} = plan.sopInstanceUid; %#ok<AGROW>
        end
    end
end

function [plans, refPlan] = collectPlansFromPatient(patient, refPlanUid)
    plans = containers.Map;
    refPlan = [];
    for i = 1:length(patient.planReferenceObjects.planUids)
        uid = patient.planReferenceObjects.planUids{i};
        if strcmp(refPlanUid, uid)
            refPlan = patient.getDicomObject(uid);
        else
            plans(uid) = patient.getDicomObject(uid);
        end
    end
end

function out = planIsEqual(plan, refPlan)
    out = false;
    
    if strcmp(refPlan.studyInstanceUid, plan.studyInstanceUid) || ...
        strcmp(refPlan.frameOfReferenceUid, plan.frameOfReferenceUid)
    
        out = true;
        return;
    end
end