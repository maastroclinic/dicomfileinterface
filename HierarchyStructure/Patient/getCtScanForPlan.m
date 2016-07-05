function ctScan = getCtScanForPlan(patient, planUid)
    structUid = patient.planReferenceObjects.rtstructsForPlan(planUid);
    if ~patient.planReferenceObjects.ctSeriesForStruct.isKey(structUid)
        ctScan = [];
        return;
    end
    uids = patient.planReferenceObjects.refUids(structUid); %assume struct and ct are in same study
    study = patient.getStudyObject(uids.studyInstanceUid);
    series = study.getSeriesObject(patient.planReferenceObjects.ctSeriesForStruct(structUid));
    ctScan = CtScan(series.getDicomObjectArray);
end