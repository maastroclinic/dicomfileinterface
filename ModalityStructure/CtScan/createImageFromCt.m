function image = createImageFromCt(ctScan, loadImageData)  
    if ~ctScan.hasUniformThickness()
        throw(MException('MATLAB:createImageFromCt', 'CT scans with changing sliceThickness are not supported'));
    end
        
    if ~isequal(ctScan.ySortedCtSlices(1).imageOrientationPatient,...
                [1;0;0;0;1;0]);
        throw(MException('MATLAB:createImageFromCt', 'Unsupported ImagePostionPatient for provided CT scan'));
    end
    
    if loadImageData
        ctScan = ctScan.readDicomData();
        image = Image(ctScan.pixelSpacingX, ctScan.pixelSpacingY, ctScan.pixelSpacingZ, ctScan.realX, ctScan.realY, ctScan.realZ, ctScan.pixelData);
    else
        image = Image(ctScan.pixelSpacingX, ctScan.pixelSpacingY, ctScan.pixelSpacingZ, ctScan.realX, ctScan.realY, ctScan.realZ, []);
    end
end