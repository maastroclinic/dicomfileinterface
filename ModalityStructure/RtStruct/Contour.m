classdef Contour
    %CONTOUR ...
    
    properties
        dicomHeader
        number
        name
        contourSlices = ContourSlice()
        closedPlanar
        forced
        relativeElectronDensity
        numberOfContourSlices
        numberOfCtSlices
        volume
        colorRgb
        referencedFrameOfReferenceUid
        y
        uniqueY
        indexUniqueY
        lowerX
        lowerY
        lowerZ
        upperX
        upperY
        upperZ
    end
    
    methods
        function this = Contour(dicomHeader)
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            this = this.parseDicomHeader(dicomHeader);
        end
        
        function this = parseDicomHeader(this, header)
            this.dicomHeader = header;
            this.contourSlices = header;
        end
        
        function this = set.contourSlices(this, dicomHeader)
            if ~isfield(dicomHeader, 'ContourSequence')
                this.contourSlices = [];
                return; 
            end
            
            items = fieldnames(dicomHeader.ContourSequence);
            this.contourSlices(1:length(items)) = ContourSlice();
            for i = 1:length(items)
                this.contourSlices(i) = ContourSlice(dicomHeader.ContourSequence.(items{i}));
            end
        end
        
        function out = get.name(this)
            if isfield(this.dicomHeader, 'ROIName')
                out = this.dicomHeader.ROIName;
            else
                out = 'N/A';
            end
        end
        
        function out = get.number(this)
            if isfield(this.dicomHeader, 'ROINumber')
                out = this.dicomHeader.ROINumber;
            else
                out = 'N/A';
            end
        end
        
        function out = get.referencedFrameOfReferenceUid(this)
            if isfield(this.dicomHeader, 'ReferencedFrameOfReferenceUID')
                out = this.dicomHeader.ReferencedFrameOfReferenceUID;
            else
                out = [];
            end
        end
        
        function out = get.numberOfContourSlices(this)
            out = length(this.contourSlices); 
        end
        
        function out = get.numberOfCtSlices(this)
            out = length(this.uniqueY);
        end
        
        function out = get.closedPlanar(this)
            out = true;
            if this.numberOfContourSlices > 0
                for i = 1:this.numberOfContourSlices
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
            out = zeros(this.numberOfContourSlices,1);
            for i = 1:this.numberOfContourSlices
                if ~isempty(this.contourSlices(i).y)
                    out(i) = this.contourSlices(i).y(1); (1); 
                else
                    out(i) = [];
                end
            end
        end
        
        function out = get.uniqueY(this)
            [out, ~, ~] = unique(this.y);
        end  
        
        function out = get.indexUniqueY(this)
            [~, ~, out] = unique(this.y);
        end
        
        function out = get.lowerX(this)
            out = min(this.contourSlices(1).x);
            for i = 2:this.numberOfContourSlices
                 out = min([out, min(this.contourSlices(i).x)]);
            end
        end
        
        function out = get.lowerY(this)
            out = min(this.y);
        end
        
        function out = get.lowerZ(this)
            out = min(this.contourSlices(1).z);
            for i = 2:this.numberOfContourSlices
                 out = min([out, min(this.contourSlices(i).z)]);
            end
        end
        
        function out = get.upperX(this)
            out = max(this.contourSlices(1).x);
            for i = 2:this.numberOfContourSlices
                 out = max([out, max(this.contourSlices(i).x)]);
            end
        end
        
        function out = get.upperY(this)
            out = max(this.y);
        end
        
        function out = get.upperZ(this)
            out = max(this.contourSlices(1).z);
            for i = 2:this.numberOfContourSlices
                 out = max([out, max(this.contourSlices(i).z)]);
            end
        end
    end
end