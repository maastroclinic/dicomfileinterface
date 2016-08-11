function [x, y, z] = determineDoseVectors( dose, doseCutOff)
    if doseCutOff == 0
%         yStart      = dose.originY;
        yStartIndex = 1;
%         yEnd        = dose.originY+dose.gridFrameOffsetVector(end);
        yEndIndex   = dose.numberOfFrames;
    else
        yStart = [];
        yEnd   = [];
        doseImage = dose.scaledImageData;
        doseMax = max(doseImage(:));
        for i = 1 : dose.numberOfFrames
            if ~isempty(find(doseImage(:,i,1,:)>doseMax*doseCutOff/100, 1)) && isempty(yStart)
                yStart      = dose.originY+dose.gridFrameOffsetVector(i);
                yStartIndex = i;
            end
            if ~isempty(find(doseImage(:,dose.numberOfFrames-i+1,1,:)>doseMax*doseCutOff/100, 1)) && isempty(yEnd)
                yEnd      = dose.originY + dose.gridFrameOffsetVector(dose.numberOfFrames  - i + 1);
                yEndIndex = dose.numberOfFrames -i + 1;
            end
        end
    end
    
    x = (dose.originX:dose.pixelSpacing(1):dose.originX+(dose.columns-1)*dose.pixelSpacing(1))';
    y = (dose.originY+dose.gridFrameOffsetVector)';
    y = (y(yStartIndex:yEndIndex));
    z = (dose.originZ:dose.pixelSpacing(2):dose.originZ+(dose.rows-1)*dose.pixelSpacing(2))';
end

