function [ dicomDb ] = addModalityDirToDb(dicomDb, rootDir, modality )
%ADDMODALITYDIRTODB [please add info on me here :<]
    modalityDir = fullfile(rootDir, modality);
    if ~exist(modalityDir, 'dir')
        return;
    end
    
    files = filesUnderFolders(modalityDir, 'detail');
    dicomDb = addDicomObjToDatabase(dicomDb, files);
end

