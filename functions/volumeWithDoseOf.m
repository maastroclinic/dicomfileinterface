% DVH info:
%   Over the last decade, three dimensional radiation therapy planning 
%   has enabled a detailed analysis of what now is commonly known as V20
%   which is the percentage of the lung volume (with subtraction of the 
%   volume involved by lung cancer) which receives radiation doses of 20 Gy
%   or more. Over the last decade, three dimensional radiation therapy 
%   planning has enabled a detailed analysis of what now is commonly known 
%   as V20 
% SOURCE http://cancergrace.org/radiation/2012/02/18/v20/
function out = volumeWithDoseOf(doseCube, pixelSpacing, doseLimit, relative, volume)
% VOLUMEWITHDOSEOF Calculate the volume (in cc or %) of the structure with at least a dose above
%   or equal to the specified dose

    out = length(find(doseCube(:) >= doseLimit)) * prod(pixelSpacing);
    
    if relative
        out = out / volume * 100;
    end

end

