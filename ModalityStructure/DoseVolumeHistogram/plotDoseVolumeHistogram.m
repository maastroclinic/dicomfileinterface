function pFig = plotDoseVolumeHistogram(dvh, pFig)
%PLOTDOSEVOLUMEHISTOGRAM 
%
%
% See also: PLOTDOSEVOLUMEHISTOGRAMS, DOSEVOLUMEHISTOGRAM, ADDDOSEVOLUMEHISTOGRAMLEGEND 

    if nargin == 1
        pFig = figure('Name', 'Dose Volume Histogram');
        pAx = axes();
        pAx.XLabel.String = 'Dose (Gy)';
        pAx.YLabel.String = 'Volume (%)';
    end
    set(0, 'currentfigure', pFig);
    hold on;
    plot(dvh.vDose, dvh.vVolumeRelative);
    hold off;
end

