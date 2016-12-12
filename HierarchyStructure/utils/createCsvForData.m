function [ status ] = createCsvForData( data, filename )
%CREATECSVFORDATA [please add info on me here :<]
    status = false;
    try
        pFile = fopen(filename, 'w+');
    catch EM
        disp(EM.message);
        return;
    end
    
    if pFile == -1
        disp('invalid filename')
        return;
    end
    
    for i = 1:size(data,1)
        string = data{i,1};
        for j = 2:size(data,2)
            string = [string ',' data{i,j}];  
        end
        string = [string 10;];
        fwrite(pFile, string);
    end
    
    try
        fclose(pFile);
    catch EM
        disp(EM.message);
        status = false;
        return;
    end
    status = true;
end

