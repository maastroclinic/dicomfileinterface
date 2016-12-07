function out = calculateImageStatistics(image, operation)
%CALCULATEIMAGESTATISTICS can calculate statistics for an Image object.
%
% out = calculateImageStatistics(image, operation) applies to operation to the provided image object
%  valid operations are: mean, max, min, sdt, median, sum
%
% See also: Image, VolumeOfInterest
    out = NaN;
    if ~isa(image, 'Image') && isempty(image.pixelData)
        throw(MException('MATLAB:calculateImageStatistics', 'please provide image object with pixel data'))
    end

    try
        switch strtrim(lower(operation))
            case 'mean'
                out = nanmean(image.pixelData(:));
            case 'max'
                out = nanmax(image.pixelData(:));
            case 'min'
                out = nanmin(image.pixelData(:));
            case 'sdt'
                out = nanstd(image.pixelData(:));
            case 'median'
                out = nanmedian(image.pixelData(:));
            case 'sum'
                out = nansum(image.pixelData(:));
            otherwise
                throw(MException('MATLAB:calculateImageStatistics','invalid operation'));
        end
    catch EM
        warning('MATLAB:calculateImageStatistics', EM.message);
    end
end