function out = minMeanMaxImage( image, operation )
    switch strtrim(lower(operation))
        case 'mean'
            out = nanmean(image(:));
        case 'max'
            out = nanmax(image(:));
        case 'min'
            out = nanmin(image(:));
        otherwise
            out = NaN;
    end
end

