if ~exist('dicomDb', 'var')
    dicomDb = DicomDatabase();
end

patients = dir(folder);
patients(1) = [];patients(1) = []; %remove .. and .

for i = 1:length(patients)
    disp(['indexing patient: ' patients(i).name])
    patientDir = fullfile(folder, patients(i).name);
    dicomDb = addPatientToDb(dicomDb, patientDir);
end