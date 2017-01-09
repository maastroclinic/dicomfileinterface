classdef CtSlice < DicomObj
    %CTSLICE represents a single CtSlice DicomObj
    %
    %CONSTRUCTOR:
    % this = CtSlice(dicomItem, useVrHeuristics) creates a CtSlice object
    %  using the full file path (or a DicomObj) and boolean to deterine the use of VR Heuristics
    %
    % See also: DICOMOBJ, CTSCAN, CONTOURSLICE
    properties
        rescaleSlope
        rescaleIntercept
        sliceThickness
        windowCenter
        windowWidth
        scaledImageData
    end
    
    methods
        function this = CtSlice(dicomItem, useVrHeuristics)
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            
            this = constructorParser(this, 'ct', dicomItem, useVrHeuristics);
        end
        % -------- START GETTERS/SETTERS ----------------------------------
        function out = get.rescaleSlope(this)
            out = this.dicomHeader.RescaleSlope;
        end
        
        function out = get.rescaleIntercept(this)
            out = this.dicomHeader.RescaleIntercept;
        end
        
        function out = get.sliceThickness(this)
            out = this.dicomHeader.SliceThickness/10; %convert to IEC
        end
        
        function out = get.windowCenter(this)
            out = this.dicomHeader.WindowCenter;
        end
        
        function out = get.windowWidth(this)
            out = this.dicomHeader.WindowWidth;
        end

        function out = get.scaledImageData(this)
            if isempty(this.pixelData)
                throw(MException('MATLAB:CtSlice:scaledImageData', 'No pixel data loaded year, please loadDicomData first'));
            end
            doubleImage = double(this.pixelData);
            out = (doubleImage * this.rescaleSlope) + this.rescaleIntercept;
            out(out<-1024) = -1024; %copied from DGRT code;
        end
    end
end