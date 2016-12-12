function hFig = plotSliceOfImage(image, sliceNr, useDefaultColorMap, hFig)
%PLOTSLICEOFIMAGE plots the pixel data of a certain slice in an Image object
%
% hFig = plotSliceOfImage(image, sliceNr) plots the slice with default settings
%
% hFig = plotSliceOfImage(image, sliceNr, useDefaultColorMap, hFig) allows to not apply the default
% colormap and chooses a certain figure handle
%
% See also: IMAGE, VOLUMEOFINTEREST, ADDCONTOURFILLTOFIGUREFROMVOI, ADDCONTOURTOFIGUREFROMVOI
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