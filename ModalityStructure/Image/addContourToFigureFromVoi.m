%this function is used to add a contour to an UNALTERED figure produced by 
% by the plotSliceOfCtScan function
function hFig = addContourToFigureFromVoi(voi, sliceNr, lineSpec, hFig)
    if nargin == 2
        lineSpec = '-b';
        hFig = figure;
    end
    
    if sliceNr > voi.slices
        MException('MATLAB:dicom-file-interface:addContourToFigureFromVoi', 'Selected slice is not present in VOI');
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

