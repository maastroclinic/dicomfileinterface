function out = imageVolume(image, pixelSpacing)
    out = nansum(image(:)) * prod(pixelSpacing);
end