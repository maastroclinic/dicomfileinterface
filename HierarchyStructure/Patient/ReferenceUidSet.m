classdef ReferenceUidSet
    %REFERENCEUIDSET [please add info on me here :<]
    % small oject to hold the keys needed to get the objects from the dicomDatabase
    
    properties
        studyInstanceUid
        seriesInstanceUid
        sopInstanceUid
        filename
    end
    
    methods
        function this = ReferenceUidSet(dicomObj)
            if nargin == 0
                return;
            end
            this.studyInstanceUid = dicomObj.studyInstanceUid;
            this.seriesInstanceUid = dicomObj.seriesInstanceUid;
            this.sopInstanceUid = dicomObj.sopInstanceUid;
            this.filename = dicomObj.filename;
        end
    end
end