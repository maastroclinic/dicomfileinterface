function dicomDb = addNewFolderToDatabase(dicomDb, folder)
    if ~exist(folder, 'dir')
        thrown(MException('MATLAB:DicomDatabase:constructor', 'provided folder is not a valid folder'))
    end

    files = filesUnderFolders(folder, 'detail');
    nrOfFiles = length(files);
    for i = 1:nrOfFiles
        if isdicom(files{i})
            if dicomDb.fileAvailableInDb(files{i})
                continue; %skip if file is already in db
            end
            
            try
                dicomObj = DicomObj(files{i}, false);
            catch EM
                %if the file fails to read for some reason continue with the rest.
                warning(['failed to read ' files{i}])
                warning(EM.message);
                continue;
            end
            dicomDb = dicomDb.parseDicomObj(dicomObj);
        end
    end
end
