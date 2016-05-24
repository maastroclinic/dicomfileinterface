function ctScan = getCtScanForPlan(patient, planUid)
    structUid = patient.rtstructsForPlan(planUid);
    if ~patient.ctSeriesForStruct.isKey(structUid)
        ctScan = [];
        return;
    end
    uids = patient.treeUids(structUid); %assume struct and ct are in same study
    study = patient.getStudyObject(uids.studyInstanceUid);
    series = study.getSeriesObject(patient.ctSeriesForStruct(structUid));
    ctScan = CtScan(series.getDicomObjectArray);
end