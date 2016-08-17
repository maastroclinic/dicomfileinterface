function hFig = addContourFillToFigureFromVoi(voi, sliceNr, color, hFig)
    if nargin == 2
        color = [0,0,0];
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
        hPath = patch(zContour, xContour, 1:length(zContour), 'FaceColor', color);
        set(hPath,'FaceAlpha', 0.5);
        set(hPath,'EdgeColor','none');
        i = i + pointsInCurrentContour + 1; %go to next contour
    end
    hold off;
end