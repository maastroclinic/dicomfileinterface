function [ dicomDb ] = addPatientToDb(dicomDb, patientDir)
%ADDPATIENTTODB [please add info on me here :<]
    disp('Adding RTPLAN objects') %iew, disp, create logger maybe?
    dicomDb = addModalityDirToDb(dicomDb, patientDir, 'RTPLAN');
    
    disp('Adding CT objects')
    dicomDb = addCtDirToDb(dicomDb, patientDir);
    
    disp('Adding RTDOSE objects')
    dicomDb = addModalityDirToDb(dicomDb, patientDir, 'RTDOSE');
    
    disp('Adding RTPLAN objects')
    dicomDb = addModalityDirToDb(dicomDb, patientDir, 'RTSTRUCT');
end

