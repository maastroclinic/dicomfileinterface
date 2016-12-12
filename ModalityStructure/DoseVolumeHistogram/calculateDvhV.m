function out = calculateDvhV(dvh, doseLimit, relativeOutput)
%CALCULATEDVHV uses a DoseVolumeHistogram to calculate a wanted DVH-V parameter in cc/Percentage
%
% out = calculateDvhV(dvh, doseLimit) is the simple calculation where the output is 
%  assumed to be absolute
%
% out = calculateDvhV( dvh, doseLimit, relative ) providing more
%  inputs will enable an relative output
%
% See also: DOSEVOLUMEHISTOGRAM, CALCULATEDVHD
    if nargin == 2
        relativeOutput = false;
    end

    index = find((dvh.vDose(:) >= doseLimit), 1, 'first');
    out = dvh.vVolume(index);
    if relativeOutput
        out = out / dvh.volume * 100;
    end
end