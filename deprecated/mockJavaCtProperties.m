function javaCtProperties = mockJavaCtProperties(CT)
    CTFiles = dir(fullfile(CT, '*.dcm'));

    header = dicominfo(fullfile(CT, CTFiles(1).name));
    for i = 2:length(CTFiles)
        nextHeader = dicominfo(fullfile(CT, CTFiles(i).name));
        if header.ImagePositionPatient(3) > nextHeader.ImagePositionPatient(3);
            header = nextHeader;
        end
    end

    javaCtProperties.PixelSpacing = header.PixelSpacing';
    javaCtProperties.SliceThickness =  header.SliceThickness;
    javaCtProperties.Rows =  header.Rows;
    javaCtProperties.Columns =  header.Columns;
    javaCtProperties.ImageOrientationPatient =  header.ImageOrientationPatient';
    javaCtProperties.ImagePositionPatient =  header.ImagePositionPatient';
    javaCtProperties.CTFileLength =  length(CTFiles);
end