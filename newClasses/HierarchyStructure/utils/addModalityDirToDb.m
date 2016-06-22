function [ dicomDb ] = addModalityDirToDb(dicomDb, rootDir, modality )
    modalityDir = fullfile(rootDir, modality);
    if ~exist(modalityDir, 'dir')
        return;
    end
    
    files = filesUnderFolders(modalityDir, 'detail');
    dicomDb = addDicomObjToDatabase(dicomDb, files);
end

