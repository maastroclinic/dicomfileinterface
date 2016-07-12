function contourBitmask = createContourMaskFromVoi( voi )
    
    newPixelData = zeros(voi.columns, voi.slices, voi.rows);
    origPixelData = voi.uncompressedPixelData;
    
    for i = voi.yCompressed(1):voi.yCompressed(end)
        voiSlice = squeeze(origPixelData(:,i,:));
        newVoiSlice = voiSlice - imerode(voiSlice, strel('disk',1));
        newPixelData(:,i,:) = newVoiSlice;
    end
    
    contourBitmask = VolumeOfInterest(voi.pixelSpacingX, ...
                            voi.pixelSpacingY, ...
                            voi.pixelSpacingY, ...
                        	voi.realX, ...
                            voi.realY, ...
                            voi.realZ, ...
                            newPixelData);
end

