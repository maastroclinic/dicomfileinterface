classdef Patient
    %PATIENT is a colletion of studies that belong to this DICOM patient set
    %
    %CONSTRUCTORS
    % this = Patient(dicomObj) returns a patient object for the provided dicomObj
    %
    % See also: DICOMDATABASE, STUDY, SERIES, DICOMOBJ, PLANREFERENCEOBJECTS, CREATEPLANPACKAGE 
    
    properties (SetAccess = 'private')
        id
        lastname
        firstname
        gender
        dateOfBirth
        studyUids
        nrOfStudies
        planReferenceObjects
    end
    
    properties (Access = 'private')
        studies
        labelsForPlan
        parsed = false
    end
    
    methods
        function this = Patient(dicomObj)
            this = createMappingStructures(this);
            if nargin == 0
                return;
            end
            
            if ~isa(dicomObj, 'DicomObj') && nargin ~= 1
                throw(MException('MATLAB:Study:constructor', 'if constructor input is given it has to be a single DicomObj'));
            end
            
            this = this.parseDicomObj(dicomObj);
        end

        function this = parseDicomObj(this, dicomObj)
        %PARSEDICOMOBJ(dicomObj) parses the DicomObj, creates a new Study obj if the study is
        % new to the Patient. And updates the planReferenceObject.
            uid = dicomObj.studyInstanceUid;
            if ~this.studies.isKey(uid)               
                this.studies(uid) = Study(dicomObj);
            else
                this.studies(uid) = this.studies(uid).parseDicomObj(dicomObj);
            end

            this.planReferenceObjects = this.planReferenceObjects.parseDicomObject(dicomObj);
            
            if ~this.parsed
                this = this.parsePatientInfo(dicomObj);
            end
        end
        
        function dicomObj = getDicomObject(this, sopInstanceUid)
        %GETDICOMOBJECT(sopInstanceUid) returns a dicomObj with provided sopInstanceUid
            series = this.getDicomObjectSeries(sopInstanceUid);
            dicomObj = series.getDicomObject(sopInstanceUid);
        end
        
        function dicomObj = getDicomModalityObject(this, sopInstanceUid)
        %GETDICOMMODALITYOBJECT(sopInstanceUid) returns a modality specific dicomObj with provided sopInstanceUid
            series = this.getDicomObjectSeries(sopInstanceUid);
            dicomObj = series.getModalityObject(sopInstanceUid);
        end
       
        function series = getDicomObjectSeries(this, sopInstanceUid)
        %GETDICOMOBJECTSERIES(sopInstanceUid) returns the series that contains the object of
        %provided sopInstanceUid
            study = this.getDicomObjectStudy(sopInstanceUid);
            series = study.getSeriesObject(uids.seriesInstanceUid);
        end
        
        function study = getDicomObjectStudy(this, sopInstanceUid)
        %GETDICOMOBJECTSTUDY(sopInstanceUid) returns the study that contains the object of provided
        %sopInstanceUid
            uids = this.planReferenceObjects.refUids(sopInstanceUid);
            study = this.getStudyObject(uids.studyInstanceUid);
        end
        
        % -------- START GETTERS/SETTERS ----------------------------------
        function out = get.nrOfStudies(this)
            out = this.studies.Count;
        end
        
        function out = getStudyObject(this, uid)
            out = [];
            if this.studies.isKey(uid)
                out = this.studies(uid);
            end
        end
        
        function out = get.studyUids(this)
            out = this.studies.keys;
        end
    end
    
    methods (Access = 'private')
        function this = createMappingStructures(this)
            this.studies = containers.Map;
            this.labelsForPlan = containers.Map;
            this.planReferenceObjects = PlanReferenceObjects();
        end
        
        function this = parsePatientInfo(this, dicomObj)
            this.id = dicomObj.patientId;
            this.lastname = dicomObj.lastname;
            this.firstname = dicomObj.firstname;
            this.gender = dicomObj.gender;
            this.dateOfBirth = dicomObj.dateOfBirth;
            this.parsed = true;
        end

    end
end