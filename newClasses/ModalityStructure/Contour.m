classdef Contour
    %CONTOUR ...
    
    properties
        dicomHeader;
        number;
        name;
        contourSlices = ContourSlice();
        closedPlanar;
        forced;
        relativeElectronDensity;
        numberOfSlices;
        volume;
        colorRgb;
        referencedFrameOfReferenceUid;
        bitmask;
        y;
        lowerX;
        lowerY;
        lowerZ;
        upperX;
        upperY;
        upperZ;
    end
    
    methods
        function this = Contour(dicomHeader)
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            this.dicomHeader = dicomHeader;
        end
        
        function this = set.dicomHeader(this, header)
            if isfield(header, 'ROIName') && ...
               isfield(header, 'ROINumber') && ...
               isfield(header, 'ContourSequence') && ...
               isfield(header, 'ROIDisplayColor')
                
                this.dicomHeader = header;
            else
                thrown(MException('MATLAB:Contour', 'invalid partial dicom header input'));
            end
        end
        
        function out = get.name(this)
            out = this.dicomHeader.ROIName;
        end
        
        function out = get.number(this)
            out = this.dicomHeader.ROINumber;
        end
        
        function out = get.contourSlices(this)
            items = fieldnames(this.dicomHeader.ContourSequence);
            out(1:length(items)) = ContourSlice();
            for i = 1:length(items)
                out(i) = ContourSlice(this.dicomHeader.ContourSequence.(items{i}));
            end
        end
        
        function out = get.referencedFrameOfReferenceUid(this)
            if isfield(this.dicomHeader, 'ReferencedFrameOfReferenceUID')
                out = this.dicomHeader.ReferencedFrameOfReferenceUID;
            else
                out = [];
            end
        end
        
        function out = get.numberOfSlices(this)
            out = length(this.contourSlices); 
        end
        
        function out = get.closedPlanar(this)
            out = true;
            if this.numberOfSlices > 0
                for i = 1:this.numberOfSlices
                     if ~this.contourSlices(i).closedPlanar
                         out = false;
                         return;
                     end
                end
            else
                out = [];
            end
        end
        
        function out = get.colorRgb(this)
            if isfield(this.dicomHeader, 'ROIDisplayColor')
                out = this.dicomHeader.ROIDisplayColor./256;
            else
                %when no color settings are available set to white. 
                out = [1 1 1]; 
            end
        end
        
        function out = get.volume(this)
            if isfield(this.dicomHeader, 'ROIVolume')
                out = this.dicomHeader.ROIVolume;
            else
                out = NaN;
            end
        end
        
        function out = get.forced(this)
            if isempty(this.relativeElectronDensity)
                out = false;
            else
                out = true;
            end
        end
        
        function out = get.relativeElectronDensity(this)
            if isfield(this.dicomHeader, 'ROIPhysicalPropertiesSequence');
                items = fieldnames(this.dicomHeader, 'ROIPhysicalPropertiesSequence');
                for i = 1:length(items)
                    out(i) = this.dicomHeader.ROIPhysicalPropertyValue.(items{1}).ROIPhysicalPropertyValue; %#ok<AGROW>
                end
            else
                out = [];
            end
        end
        
        function out = get.y(this)
            out = zeros(this.numberOfSlices,1);
            for i = 1:this.numberOfSlices
                out(i) = this.contourSlices(i).y(1); 
            end
        end
        
        function out = get.lowerX(this)
            out = min(this.contourSlices(1).x);
            for i = 2:this.numberOfSlices
                 out = min([out, min(this.contourSlices(i).x)]);
            end
        end
        
        function out = get.lowerY(this)
            out = min(this.y);
        end
        
        function out = get.lowerZ(this)
            out = min(this.contourSlices(1).z);
            for i = 2:this.numberOfSlices
                 out = min([out, min(this.contourSlices(i).z)]);
            end
        end
        
        function out = get.upperX(this)
            out = max(this.contourSlices(1).x);
            for i = 2:this.numberOfSlices
                 out = max([out, max(this.contourSlices(i).x)]);
            end
        end
        
        function out = get.upperY(this)
            out = max(this.y);
        end
        
        function out = get.upperZ(this)
            out = max(this.contourSlices(1).z);
            for i = 2:this.numberOfSlices
                 out = max([out, max(this.contourSlices(i).z)]);
            end
        end
    end
end