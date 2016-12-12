function [ dicomDb ] = addDicomObjToDatabase( dicomDb, files )
%ADDDICOMOBJTODATABASE [please add info on me here :<]
    if isempty(files)
        return;
    end
    
    if ~dicomDb.fileAvailableInDb(files{1})
        dicomDb = dicomDb.parseDicomObj(DicomObj(files{1}, false));
    end
    
    files(1) = [];
    dicomDb = addDicomObjToDatabase(dicomDb, files);
end