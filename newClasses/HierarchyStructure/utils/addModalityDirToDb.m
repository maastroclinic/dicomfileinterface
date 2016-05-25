function [ dicomDb ] = addModalityDirToDb(dicomDb, rootDir, modality )
    modalityDir = fullfile(rootDir, modality);
    if exist(modalityDir, 'dir')
        files = filesUnderFolders(modalityDir, 'detail');
        for i = 1:length(files);
            if dicomDb.fileAvailableInDb(files{i})
                continue; %skip if file is already in db
            end
            
            disp(['processing ' num2str(i) ' of ' num2str(length(files))])
            dicomDb = dicomDb.parseDicomObj(DicomObj(files{i}, false)); 
        end
    end
end

