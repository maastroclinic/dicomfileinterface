classdef DicomDatabase
    %DICOMDATABASE scans a folder for dicom files and creates a patient/study/series model for each
    %dicom file found.
    %
    %CONSTRUCTORS
    % this = DicomDatabase(folder) returns a DicomDatabase object that has read all available files
    %   in the provided folder and subfolders.
    %
    % See also: PATIENT, STUDY, SERIES, DICOMOBJ, ADDNEWFOLDERTODATABASE
    properties
        patientIds
        nrOfPatients
        filesInDb
    end
    
    properties (Access = 'private')
        patients
    end
    
    methods
        function this = DicomDatabase(folder)
            this.patients = containers.Map;
            this.filesInDb = containers.Map;
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            this = addNewFolderToDatabase(this, folder);
        end
        
        function this = parseDicomObj(this, dicomObj)
        %PARSEDICOMOBJ(dicomObj) parses the DicomObj, creates a new Patient obj if the patient is
        % new to the Database.
            id = dicomObj.patientId;
            if ~this.patients.isKey(id)
                this.patients(id) = Patient(dicomObj);
            else
                this.patients(id) = this.patients(id).parseDicomObj(dicomObj);
            end
            this.filesInDb(dicomObj.filename) = true;
        end
        
        function out = getPatientObject(this, patientId)
        %GETPATIENTOBJ(this, patientId) returns Patient matching patientId
            out = [];
            if this.patients.isKey(patientId)
                out = this.patients(patientId);
            end
        end 
        
        function out = fileAvailableInDb(this, fileStr)
        %FILEAVAILABLEINDB(file) checks if the provided fullfile is available in the DicomDatabase
            out = false;
            if this.filesInDb.isKey(fileStr)
                out = true;
            end
        end
        
        % -------- START GETTERS/SETTERS ----------------------------------
        function out = get.nrOfPatients(this)
            out = this.patients.Count;
        end
        
        function out = get.patientIds(this)
            out = this.patients.keys;
        end
    end
end