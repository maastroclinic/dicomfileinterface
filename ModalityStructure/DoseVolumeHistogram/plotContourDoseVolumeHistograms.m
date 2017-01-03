function pFig = plotContourDoseVolumeHistograms(dvhs, contours)
%PLOTCONTOURDOSEVOLUMEHISTOGRAMS 
    if length(dvhs) ~= length(contours)
        throw(MException('Matlab:plotContourDoseVolumeHistograms:InvalidInput', 'Please provide the same number of dvhs as contours')) 
    end
    pFig = plotDoseVolumeHistograms(dvhs, {contours.colorRgb}, regexprep({contours.name},'_',' '));
end

