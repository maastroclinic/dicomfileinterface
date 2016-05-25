function [ dicomDb ] = addPatientToDb(dicomDb, patientDir)
    disp('Adding RTPLAN objects')
    dicomDb = addModalityDirToDb(dicomDb, patientDir, 'RTPLAN');
    
    disp('Adding CT objects')
    dicomDb = addCtDirToDb(dicomDb, patientDir);
    
    disp('Adding RTDOSE objects')
    dicomDb = addModalityDirToDb(dicomDb, patientDir, 'RTDOSE');
    
    disp('Adding RTPLAN objects')
    dicomDb = addModalityDirToDb(dicomDb, patientDir, 'RTSTRUCT');
end

