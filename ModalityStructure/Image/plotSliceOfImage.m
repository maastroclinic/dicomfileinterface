function hFig = plotSliceOfImage(image, sliceNr, useDefaultColorMap, hFig)
    if nargin < 3
        useDefaultColorMap = true;
        hFig = figure;
    end
    
    if sliceNr > image.slices
        throw(MException('MATLAB:dicomfileinterface:plotSliceOfImage', 'Selected slice is not present in CtScan'));
    end
    
    if isempty(image.pixelData)
        throw(MException('MATLAB:dicomfileinterface:plotSliceOfImage', 'Provided does not have any loaded image data'));
    end
    
    if useDefaultColorMap
        scale = gray(2000);
        color = scale(1:end, :);
        colormap(color);
    end
    
    slice = double(squeeze(image.pixelData(:,sliceNr,:)));
    imagesc(slice);
end