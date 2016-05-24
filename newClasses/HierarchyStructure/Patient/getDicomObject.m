function dicomObj = getDicomObject(patient, sopInstanceUid, asModalityObject)
    uids = patient.treeUids(sopInstanceUid);
    study = patient.getStudyObject(uids.studyInstanceUid);
    series = study.getSeriesObject(uids.seriesInstanceUid);
    if asModalityObject 
        dicomObj = series.getModalityObject(sopInstanceUid);
    else
        dicomObj = series.getDicomObject(sopInstanceUid);
    end
end