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
            this = this.scanFolder(folder);
        end

        function this = scanFolder(this, folder)
            if ~exist(folder, 'dir')
                thrown(MException('MATLAB:DicomDatabase:constructor', 'provided folder is not a valid folder'))
            end
            
            files = filesUnderFolders(folder, 'detail');
            nrOfFiles = length(files);            
            for i = 1:nrOfFiles
                disp([num2str(i) '/' num2str(nrOfFiles)]);
                if isdicom(files{i})
                    try
                        dicomObj = DicomObj(files{i}, false);
                    catch EM
                        %if the file fails to read for some reason continue with the rest.
                        warning(['failed to read ' files{i}])
                        warning(EM.message);
                        continue; 
                    end
                    this = this.parseDicomObj(dicomObj);
                end
            end
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