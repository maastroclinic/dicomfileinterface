function hFig = plotCtSlice(ctSlice, hFig)
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