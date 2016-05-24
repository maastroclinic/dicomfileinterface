classdef DicomDatabase
    %DICOMDATABASE
    
    properties
        patientIds
        nrOfPatients
    end
    
    properties (Access = 'private')
        patients
    end
    
    methods
        function this = DicomDatabase(folder)
            this.patients = containers.Map;
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            this = addNewFolderToDatabase(this, folder);
        end
        
        function this = parseDicomObj(this, dicomObj)
            id = dicomObj.patientId;
            if ~this.patients.isKey(id)
                this.patients(id) = Patient(dicomObj);
            else
                this.patients(id) = this.patients(id).parseDicomObj(dicomObj);
            end
        end
   
        function out = get.nrOfPatients(this)
            out = this.patients.Count;
        end
        
        function out = get.patientIds(this)
            out = this.patients.keys;
        end
        
        function out = getPatientObject(this, patientId)
            out = [];
            if this.patients.isKey(patientId)
                out = this.patients(patientId);
            end
        end      
    end
end