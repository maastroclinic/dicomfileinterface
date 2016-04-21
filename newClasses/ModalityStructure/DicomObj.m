classdef DicomObj
    %DICOMOBJ basic DICOM object that can be extended for other modalities
    
    properties
        %store the unprocessed DICOM header in here.
        dicomHeader;
       
        patientId;
        studyInstanceUid;
        seriesInstanceUid;
        sopInstanceUid;
        frameOfReferenceUid;
        modality;
    end
    
    methods
        function this = DicomObj(fileStr, useVrHeuristic) %do not know if this should be varargin
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            
            this = this.readDicomFile(fileStr, useVrHeuristic);
        end
        
        function this = readDicomFile(this, fileName, useVrHeuristic)
            if ~exist(fileName, 'file')
                fnErrorString = regexprep(fileName,'\','\\\');
                throw(MException('MATLAB:dicomObj:readDicomFile', ['DICOM file ''' fnErrorString ''' not found.''']));
            end
            
            this.dicomHeader = dicominfo(fileName, 'UseVRHeuristic', useVrHeuristic);
        end
        
        function this = set.dicomHeader(this, header)
            if isfield(header, 'Format') && strcmpi(header.Format, 'dicom')
                this.dicomHeader = header;
            else
                throw(MException('MATLAB:dicomObj:setdicomHeader','the provided input is an invalid dicom header'));
            end
        end
        
        function out = get.patientId(this)
            out = this.dicomHeader.PatientID;
        end
        
        function out = get.studyInstanceUid(this)
            out = this.dicomHeader.StudyInstanceUID;
        end
        
        function out = get.seriesInstanceUid(this)
            out = this.dicomHeader.SeriesInstanceUID;
        end
        
        function out = get.sopInstanceUid(this)
            out = this.dicomHeader.SOPInstanceUID;
        end
        
        function out = get.frameOfReferenceUid(this)
            out = this.dicomHeader.FrameOfReferenceUID;
        end
        
        function out = get.modality(this)
            out = this.dicomHeader.Modality;
        end
    end
    
end

