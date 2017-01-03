function pFig = plotDoseVolumeHistograms( dvhs, colors, names )
%PLOTDOSEVOLUMEHISTOGRAMS plots a collection of DoseVolumeHistogram Objects
%
%
% See also: PLOTDOSEVOLUMEHISTOGRAM, DOSEVOLUMEHISTOGRAM, ADDDOSEVOLUMEHISTOGRAMLEGEND 

    if nargin == 1
        colors(1:length(dvhs)) = {[0,0,0]}; %#ok<NASGU>
        names(1:length(dvhs)) = {'Unknown DVH object'};
    end

    pFig = plotDoseVolumeHistogram(dvhs(1));
    
    for i = 2:length(dvhs)
         pFig = plotDoseVolumeHistogram(dvhs(i), pFig);
    end
    
    legend(names);
end

