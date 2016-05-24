classdef Patient
    %PATIENT
    
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
            uid = dicomObj.studyInstanceUid;
            if ~this.studies.isKey(uid)               
                this.studies(uid) = Study(dicomObj);
            else
                this.studies(uid) = this.studies(uid).parseDicomObj(dicomObj);
            end

            this.planReferenceObjects = this.planReferenceObjects.parseDicomObject(dicomObj);
            
            if ~this.parsed %only parse info for first object
                this = this.parsePatientInfo(dicomObj);
            end
        end
        
        function this = set.id(this, dicomHeader)
            if isfield(dicomHeader, 'PatientID')
                this.id = dicomHeader.PatientID;
            end
        end
        
        function this = set.lastname(this, dicomHeader)
            if isfield(dicomHeader, 'PatientName') && isfield(dicomHeader.PatientName, 'FamilyName')
                this.lastname = dicomHeader.PatientName.FamilyName;
            end
        end
        
        function this = set.firstname(this, dicomHeader)
            if isfield(dicomHeader, 'PatientName') && isfield(dicomHeader.PatientName, 'FirstName')
                this.firstname = dicomHeader.PatientName.FirstName;
            end
        end
        
        function this = set.gender(this, dicomHeader)
            if isfield(dicomHeader, 'PatientSex')
                this.gender = dicomHeader.PatientSex;
            end
        end
        
        function this = set.dateOfBirth(this, dicomHeader)
            if isfield(dicomHeader, 'PatientBirthDate')
                this.dateOfBirth = dicomHeader.PatientBirthDate;
            end
        end
        
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
        
        function dicomObj = getDicomObject(this, sopInstanceUid)
            series = this.getDicomObjectSeries(sopInstanceUid);
            dicomObj = series.getDicomObject(sopInstanceUid);
        end
        
        function dicomObj = getDicomModalityObject(this, sopInstanceUid)
            series = this.getDicomObjectSeries(sopInstanceUid);
            dicomObj = series.getModalityObject(sopInstanceUid);
        end
        
        function series = getDicomObjectSeries(this, sopInstanceUid)
            uids = this.planReferenceObjects.refUids(sopInstanceUid);
            study = this.getStudyObject(uids.studyInstanceUid);
            series = study.getSeriesObject(uids.seriesInstanceUid);
        end
    end
    
    methods (Access = 'private')
        function this = createMappingStructures(this)
            this.studies = containers.Map;
            this.labelsForPlan = containers.Map;
            this.planReferenceObjects = PlanReferenceObjects();
        end
        
        function this = parsePatientInfo(this, dicomObj)
            this.id = dicomObj.dicomHeader;
            this.lastname = dicomObj.dicomHeader;
            this.firstname = dicomObj.dicomHeader;
            this.gender = dicomObj.dicomHeader;
            this.dateOfBirth = dicomObj.dicomHeader;
            this.parsed = true;
        end

    end
end