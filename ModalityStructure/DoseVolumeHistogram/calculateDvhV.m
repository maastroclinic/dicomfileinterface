function out = calculateDvhV( dvh, doseLimit, relative )
    if nargin == 2
        relative = false;
    end

    index = find((dvh.vDose(:) >= doseLimit), 1, 'first');
    out = dvh.vVolume(index);
    if relative
        out = out / dvh.volume * 100;
    end
end