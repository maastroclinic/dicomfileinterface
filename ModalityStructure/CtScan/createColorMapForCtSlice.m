function color = createColorMapForCtSlice( ctSlice, center, window )
    
huMin = min(ctSlice.scaledImageData(:));
huMax = max(ctSlice.scaledImageData(:));

grayScale = gray(window+1);
range = huMin:huMax;

lowerBound = center-(1/2*window);
if lowerBound > huMin
    iLowerLimit = find(range == lowerBound);
    iLowerScale = 1;
else
    iLowerLimit = 1;
    iLowerScale = huMin - lowerBound + 1;
end

upperBound = center+(1/2*window);
if upperBound < huMax
    iUpperLimit = find(range == upperBound);
    iUpperScale = length(grayScale);
else
    iUpperLimit = length(range)-1;
    iUpperScale = huMax - lowerBound;
end
color = zeros((huMax-huMin), 3);
color(iLowerLimit:iUpperLimit, :) = grayScale(iLowerScale:iUpperScale,:);
color(iUpperLimit:end,:) = 1;
% colormap(color);

end

