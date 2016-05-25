if ~exist('dicomDb', 'var')
    disp('please run loopOverPatientDirs first');
end

patientIds = dicomDb.patientIds;
data = [];
first = true;
for i = 1:dicomDb.nrOfPatients
    patient = dicomDb.getPatientObject(patientIds{i});
    
    plans = patient.planReferenceObjects.planLabels;
    for j = 1:(length(plans))
        try
            tmpData = createListDicomObjectsForPlan(patient, plans{j}, true);
            if first
                data = tmpData;
                first = false;
            else
                data = [data; tmpData(2:end, :)]; %#ok<AGROW>
            end
        catch 
            disp([patientIds{j} ', ' plans{j} ' does not have a complete dicom set'])
        end
    end
end