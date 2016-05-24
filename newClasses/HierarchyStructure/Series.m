classdef Series
    %SERIES 
    
    properties (SetAccess = 'private')
        id
        description
        modality
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
%             dicomObj = this.createModalityObj(dicomObj);
            this.images(dicomObj.sopInstanceUid) = dicomObj;

            if this.images.Count == 1 %only parse info for first object
                this = this.parseSeriesInfo(dicomObj);
            end
        end
        
        function this = parseSeriesInfo(this, dicomObj)
            this.id = dicomObj.seriesInstanceUid;
            this.description = dicomObj.dicomHeader.SeriesDescription;
            this.modality = dicomObj.modality;
            this.parsed = true;
        end
        
        function dicomObj = createModalityObj(~, dicomObj)
            switch dicomObj.modality
                case 'ct'
                    dicomObj = CtSlice(dicomObj, []);
                case 'rtplan'
                    dicomObj = RtPlan(dicomObj, []);
                case 'rtstruct'
                    dicomObj = RtStruct(dicomObj, []);
                case 'rtdose'
                    dicomObj = RtDose(dicomObj, []);
                case 'rtimage'
                    dicomObj = RtImage(dicomObj, []);
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
        
        function out = getDicomObjectArray(this)
            keys = this.images.keys;
            out = DicomObj();
            for i = 1:this.images.Count
                out(i) = this.images(keys{i});
            end
        end
        
        function out = getModalityObject(this, uid)
            out = [];
            if this.images.isKey(uid)
                obj = this.images(uid);
                out = this.createModalityObj(obj);
            end
        end
    end
end