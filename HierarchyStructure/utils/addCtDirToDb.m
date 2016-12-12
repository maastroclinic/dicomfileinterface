function [ dicomDb ] = addCtDirToDb(dicomDb, rootDir )
%ADDCTDIRTODB [please add info on me here :<]
    modalityDir = fullfile(rootDir, 'CT');
    if exist(modalityDir, 'dir')
        seriesDirs = dir(modalityDir);
        seriesDirs(1) = []; seriesDirs(1) = [];
        for i = 1:length(seriesDirs)
            files = filesUnderFolders(fullfile(modalityDir, seriesDirs(i).name), 'detail');
            
            if dicomDb.fileAvailableInDb(files{1})
                continue; %skip if file is already in db
            end
            
            disp(['processing ' num2str(i) ' of ' num2str(length(seriesDirs))])
            dicomDb = dicomDb.parseDicomObj(DicomObj(files{1}, false)); 
        end
    end
end