function hFig = plotCtSlice(ctSlice, hFig)
%PLOTCTSLICE plots a provided CtSlice
%
% hFig = plotCtSlice(ctSlice) plots the pixel data of ctSlice. the object needs to be
%   initialized correctly using CtSlice.readDicomData() before any pixel data is present
%
% hFig = plotCtSlice(ctSlice, hFig) plots the pixel data of ctSlice to the provided figure
%  handle
    if nargin == 1
        hFig = figure;
    end
    
    setColorMap();
    imagesc(ctSlice.pixelData);
end

function setColorMap()
    scale = gray(2000);
    color = scale(1:end, :);
    colormap(color);
end