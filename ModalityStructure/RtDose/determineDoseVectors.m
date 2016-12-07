function [x, y, z] = determineDoseVectors(dose, doseCutOff)
%DETERMINEDOSEVECTORS returns 3 axis of the RtDose object to represent the RtDose binary data as an
% Image object
%
% [x, y, z] = determineDoseVectors(dose, doseCutOff) creates an axis array using the RtDose object
% and a doseCutOff is percentage (example, 50 provides the [x,y,z] to create a 50% dose image). 
%
% See also: RTDOSE, CREATEIMAGEFROMRTDOSE
    if doseCutOff == 0
        yStartIndex = 1;
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

