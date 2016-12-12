function hFig = addContourToFigureFromVoi(voi, sliceNr, lineSpec, hFig)
%ADDCONTOURTOFIGUREFROMVOI is used to add a contour to an UNALTERED figure produced by 
% by the plotCtSlice function
%
% hFig = addContourToFigureFromVoi(voi, sliceNr) basic plot
%
% hFig = addContourToFigureFromVoi(voi, sliceNr, lineSpec, hFig) specify the line options of the
%  figure to use.
%
% See also: PLOTCTSLICE, VOLUMEOFINTEREST, ADDCONTOURFILLTOFIGUREFROMVOI
    if nargin == 2
        lineSpec = '-b';
        hFig = figure;
    end
    
    if sliceNr > voi.slices
        warning('Selected slice is not present in VOI, returning');
        return;
    end
    
    slice = double(squeeze(voi.uncompressedPixelData(:,sliceNr,:)));
    drawContour = contourc(1:512,1:512, slice , [.5 .5]);
    
    indexOfLastContour = size(drawContour,2);
    i = 1;
    
    hold on;
    while i < indexOfLastContour
        pointsInCurrentContour = drawContour(2,i);
        xContour = drawContour(2, i+1:i+pointsInCurrentContour);
        zContour = drawContour(1, i+1:i+pointsInCurrentContour);
        plot(zContour,xContour, lineSpec, 'LineWidth', 2);
        i = i + pointsInCurrentContour + 1; %go to next contour
    end
    hold off;
end

