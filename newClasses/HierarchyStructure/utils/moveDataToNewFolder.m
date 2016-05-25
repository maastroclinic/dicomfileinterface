function [ status ] = moveDataToNewFolder(data, targetLocation )
    if ~exist(targetLocation, 'dir')
        throw(MException('MATLAB:moveDataToNewFolder', 'folder does not exist'));
    end
    
    for i = 2:size(data,1)
        patientId = data{i,1};
        planId = data{i,2};
        modality = data{i,3};
        fileLocation  = data{i,7};
        
        copyDir = fullfile(targetLocation, patientId, planId, modality);
        if ~exist(copyDir,'dir')
            mkdir(copyDir); 
        end
        
        if strcmpi('ct', modality)
            root = fileLocation;
            files = dir(root);
            files(1) = [];files(1) = []; %remove . and ..
            for j = 1:length(files)
                fileLocation = fullfile(root, files(j).name);
                copyfile(fileLocation, copyDir);
            end            
        end
        
        copyfile(fileLocation, copyDir);
    end
    
    status = true;
end

