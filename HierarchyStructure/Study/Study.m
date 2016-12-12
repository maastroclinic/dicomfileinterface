classdef Study
    %STUDY [please add info on me here :<]
    
    properties
        id
        description
        nrOfSeries
        seriesUids
    end
    
    properties (Access = 'private')
        series
        parsed = false
    end
    
    methods
        function this = Study(dicomObj)
            this.series = containers.Map;
            if nargin == 0
                return;
            end
            
            if ~isa(dicomObj, 'DicomObj') && nargin ~= 1
                throw(MException('MATLAB:Study:constructor', 'if constructor input is given it has to be a single DicomObj'));
            end
            
            this = this.parseDicomObj(dicomObj);
        end
        
        function this = parseDicomObj(this, dicomObj)
            uid = dicomObj.seriesInstanceUid;
            if ~this.series.isKey(uid)               
                this.series(uid) = Series(dicomObj);
            else
                this.series(uid) = this.series(uid).parseDicomObj(dicomObj);
            end

            if ~this.parsed %only parse info for first object
                this = this.parseStudyInfo(dicomObj);
            end
        end
        
        function this = parseStudyInfo(this, dicomObj)
            this.id = dicomObj.studyInstanceUid;
            this.parsed = true;
        end

        function out = get.nrOfSeries(this)
            out = this.series.Count;
        end
        
        function out = get.seriesUids(this)
             out = this.series.keys;
        end
        
        function out = getSeriesObject(this, uid)
            out = [];
            if this.series.isKey(uid)
                out = this.series(uid);
            end
        end
    end
    
end

