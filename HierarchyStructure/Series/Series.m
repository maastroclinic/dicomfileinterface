classdef Series
    %SERIES 
    
    properties (SetAccess = 'private')
        id
        description
        modality
        imageUids
        nrOfImages
    end
    
    properties (Access = 'private')
        images
        parsed = false
    end
    
    methods
        function this = Series(dicomObj)
            this.images = containers.Map;
            
            if nargin == 0
                return;
            end
            
            if ~isa(dicomObj, 'dicomObj') && nargin ~= 1
                throw(MException('MATLAB:Series:constructor', 'if constructor input is given it has to be a single DicomObj'));
            end
            
            this = this.parseDicomObj(dicomObj);
        end
        
        function this = parseDicomObj(this, dicomObj)
            if this.images.isKey(dicomObj.sopInstanceUid)
                return; 
            end %return, file already parsed
            
            this.images(dicomObj.sopInstanceUid) = dicomObj;

            if this.images.Count == 1 %only parse info for first object
                this = this.parseSeriesInfo(dicomObj);
            end
        end
        
        function out = get.nrOfImages(this)
            out = this.images.Count;
        end
        
        function out = getDicomObject(this, uid)
            out = [];
            if this.images.isKey(uid)
                out = this.images(uid);
            end
        end
        
        function out = get.imageUids(this)
             out = this.images.keys;
        end
        
        function out = getDicomObjectArray(this)
            keys = this.images.keys;
            out = DicomObj();
            for i = 1:this.images.Count
                out(i) = this.images(keys{i});
            end
        end
    end
    
    methods (Access = 'private')
        function this = parseSeriesInfo(this, dicomObj)
            this.id = dicomObj.seriesInstanceUid;
            this.description = dicomObj.seriesDescription;
            this.modality = dicomObj.modality;
            this.parsed = true;
        end
    end
end