function [ fileNames ] = scanFolder( folder, fileExtension )
    if ~ischar(folder) || ~ischar(fileExtension)
        throw(MException('MATLAB:scanFolder', 'folder and fileExtension have to be strings'));
    end

    if exist(folder, 'dir')
        files = dir(fullfile(folder, fileExtension));
        for i = 1:length(files)
            fileNames{i} = fullfile(folder, files(i).name);
        end
    else
        throw(MException('MATLAB:scanFolder', 'invalid folder input'));
    end
end

