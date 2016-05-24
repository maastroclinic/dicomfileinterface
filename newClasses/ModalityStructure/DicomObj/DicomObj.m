classdef DicomObj
    %DICOMOBJ basic DICOM object that can be extended for other modalities
    
    properties
        %store the unprocessed DICOM header in here.
        dicomHeader
       
        patientId
        studyInstanceUid
        seriesInstanceUid
        seriesDescription
        sopInstanceUid
        frameOfReferenceUid
        modality
        pixelData
        filename
        x %in cm
        y %in cm
        z %in cm
        rows %same as heigth
        columns %same as width
        pixelSpacing
        imageOrientationPatient
        imagePositionPatient
        instanceNumber
        
        firstname
        lastname
        gender
        dateOfBirth
        
        manufacturer
        manufacturerModelName
    end
    
    properties (Access = private)
        bufferPixelData; 
    end
    
    methods
        function this = DicomObj(fileStr, useVrHeuristic, varargin) %do not know if this should be varargin            
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            
            this = this.readDicomHeader(fileStr, useVrHeuristic);
            
            %optional boolean to read data when creating the object
            if nargin > 2 && islogical(varargin{3})
                if varargin{3} == true
                    this = this.readDicomData();
                end
            end
        end
        
        function this = readDicomHeader(this, fileName, useVrHeuristic)
            if ~exist(fileName, 'file')
                fnErrorString = regexprep(fileName,'\','\\\');
                throw(MException('MATLAB:dicomObj:readDicomFile', ['DICOM file ''' fnErrorString ''' not found.''']));
            else
                if ~isdicom(fileName)
                    fnErrorString = regexprep(fileName,'\','\\\');
                    throw(MException('MATLAB:dicomObj:readDicomFile', ['File ''' fnErrorString ''' is not a valid dicom file''']));
                end
            end
            
            this.dicomHeader = dicominfo(fileName, 'UseVRHeuristic', useVrHeuristic);
        end
        
        function this = readDicomData(this)
            fileName = this.dicomHeader.Filename;

            if ~exist(fileName, 'file')
                fnErrorString = regexprep(fileName,'\','\\\');
                throw(MException('MATLAB:dicomObj:readDicomFile', ['DICOM file ''' fnErrorString ''' not found.''']));
            end

            this.pixelData = dicomread(fileName);
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
        
        function out = get.seriesDescription(this)
            out = [];
            if isfield(this.dicomHeader, 'SeriesDescription')
                out = this.dicomHeader.SeriesDescription;
            end
        end
        
        function out = get.sopInstanceUid(this)
            out = this.dicomHeader.SOPInstanceUID;
        end
        
        function out = get.frameOfReferenceUid(this)
            out = [];
            if isfield(this.dicomHeader, 'FrameOfReferenceUID')
                out = this.dicomHeader.FrameOfReferenceUID;
            elseif isfield(this.dicomHeader, 'ReferencedFrameOfReferenceSequence')
                out = this.dicomHeader.ReferencedFrameOfReferenceSequence.Item_1.FrameOfReferenceUID;
            end
        end
        
        function out = get.filename(this)
            out = this.dicomHeader.Filename;
        end
        
        function out = get.modality(this)
            out = lower(this.dicomHeader.Modality);
        end
        
        function out = get.rows(this)
            if isfield(this.dicomHeader, 'Rows')
            	out = double(this.dicomHeader.Rows);
            else
                out = [];
            end
        end
        
        function out = get.columns(this)
            if isfield(this.dicomHeader, 'Columns')
                out = double(this.dicomHeader.Columns);
            else
                out = [];
            end
        end
        
        function out = get.pixelSpacing(this)
            if isfield(this.dicomHeader, 'PixelSpacing')
                out = this.dicomHeader.PixelSpacing/10; %convert to IEC (cm)
            else
                out = [];
            end
        end
        
        function out = get.imageOrientationPatient(this)
            if isfield(this.dicomHeader, 'ImageOrientationPatient')
                out = this.dicomHeader.ImageOrientationPatient;
            else
                out = [];
            end
        end
        
        function out = get.imagePositionPatient(this)
            if isfield(this.dicomHeader, 'ImagePositionPatient')
                out = this.dicomHeader.ImagePositionPatient;
            else
                out = [];
            end
        end
        
        function out = get.x(this)
            if isfield(this.dicomHeader, 'ImagePositionPatient')
                out = this.dicomHeader.ImagePositionPatient(1)/10; %convert to IEC (cm)
            else
                out = [];
            end
        end
        
        function out = get.y(this)
            if isfield(this.dicomHeader, 'ImagePositionPatient')
                out = this.dicomHeader.ImagePositionPatient(3)/10; %convert to IEC (cm)
            else
                out = [];
            end
        end
        
        function out = get.z(this)
            if isfield(this.dicomHeader, 'ImagePositionPatient')
                out = this.dicomHeader.ImagePositionPatient(2)/10; %convert to IEC (cm)
            else
                out = [];
            end
        end
        
        function out = get.lastname(this)
            out = [];
            if isfield(this.dicomHeader, 'PatientName') && isfield(this.dicomHeader.PatientName, 'FamilyName')
                out = this.dicomHeader.PatientName.FamilyName;
            end
        end
        
        function out = get.firstname(this)
            out = [];
            if isfield(this.dicomHeader, 'PatientName') && isfield(this.dicomHeader.PatientName, 'FirstName')
                out = this.dicomHeader.PatientName.FirstName;
            end
        end
        
        function out = get.gender(this)
            out = [];
            if isfield(this.dicomHeader, 'PatientSex')
                out = this.dicomHeader.PatientSex;
            end
        end
        
        function out = get.dateOfBirth(this)
            out = [];
            if isfield(this.dicomHeader, 'PatientBirthDate')
                out = this.dicomHeader.PatientBirthDate;
            end
        end
        
        function out = get.instanceNumber(this)
            out = [];
            if isfield(this.dicomHeader, 'InstanceNumber')
                out = this.dicomHeader.InstanceNumber;
            end
        end
        
        function out = get.manufacturer(this)
            out = [];
            if isfield(this.dicomHeader, 'Manufacturer')
                out = lower(this.dicomHeader.Manufacturer);
            end
        end
        
        function out = get.manufacturerModelName(this)
            out = [];
            if isfield(this.dicomHeader, 'ManufacturerModelName')
                out = lower(this.dicomHeader.ManufacturerModelName);
            end
        end
    end
end