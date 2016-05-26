function out = calculateDvhV( dvh, doseLimit, relative )
    index = find((dvh.vDose(:) >= doseLimit), 1, 'first');
    out = dvh.vVolume(index);
    if relative
        out = out / dvh.volume * 100;
    end
end