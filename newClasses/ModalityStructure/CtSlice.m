classdef CtSlice < DicomObj
    %CTSLICE 
    
    properties
        instanceNumber;
        y;
        rows; %same as heigth
        columns; %same as width
        pixelSpacing;
        rescaleSlope;
        rescaleIntercept;
        sliceThickness;
        windowCenter;
        windowWidth;
        imageOrientationPatient;   
        scaledImageData;
    end
    
    methods
        function this = CtSlice(varargin)
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            
            this = constructorParser(this, 'ct', varargin{1}, varargin{2});
        end
        
        function out = get.instanceNumber(this)
            out = this.dicomHeader.InstanceNumber;
        end
        
        function out = get.rows(this)
            out = this.dicomHeader.Rows;
        end
        
        function out = get.columns(this)
            out = this.dicomHeader.Columns;
        end
        
        function out = get.pixelSpacing(this)
            out = this.dicomHeader.PixelSpacing;
        end
        
        function out = get.rescaleSlope(this)
            out = this.dicomHeader.RescaleSlope;
        end
        
        function out = get.rescaleIntercept(this)
            out = this.dicomHeader.RescaleIntercept;
        end
        
        function out = get.sliceThickness(this)
            out = this.dicomHeader.SliceThickness;
        end
        
        function out = get.windowCenter(this)
            out = this.dicomHeader.WindowCenter;
        end
        
        function out = get.windowWidth(this)
            out = this.dicomHeader.WindowWidth;
        end
        
        function out = get.imageOrientationPatient(this)
            out = this.dicomHeader.ImageOrientationPatient; 
        end
        
        function out = get.y(this)
            out = this.dicomHeader.ImagePositionPatient(3);
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