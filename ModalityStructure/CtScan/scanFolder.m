function [ fileNames ] = scanFolder( folder, fileExtension )
    if ~(nargin==2)
        throw(MException('MATLAB:scanFolder', 'folder and fileExtension have to be given as input'));
    end
    
    if ~ischar(folder) || ~ischar(fileExtension)
        throw(MException('MATLAB:scanFolder', 'folder and fileExtension have to be strings'));
    end

    if exist(folder, 'dir')
        files = dir(fullfile(folder, fileExtension));
        for i = 1:length(files)
            fileNames{i} = fullfile(folder, files(i).name); %#ok<AGROW>
        end
    else
        throw(MException('MATLAB:scanFolder', 'invalid folder input'));
    end
end