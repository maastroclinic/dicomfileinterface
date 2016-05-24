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
        
        labelsForPlan
        rtdoseForPlan
        rtimageForPlan
        rtstructsForPlan
        ctSeriesForStruct
        treeUids
    end
    
    properties (Access = 'private')
        studies
        
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

            this = this.parseIdentifiers(dicomObj);
            
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
        
        function rtdose = getRtDoseForPlan(this, planUid)
            if ~this.rtdoseForPlan.isKey(planUid)
                rtdose = [];
                return;
            end
            list = this.rtdoseForPlan(planUid);
            rtdose = RtDose();
            for i = 1:length(list)
                rtdose(i) = this.getDicomModalityObject(list(i).sopInstanceUid);
            end
        end
        
        function rtimage = getRtImageForPlan(this, planUid)
            if ~this.rtimageForPlan.isKey(planUid)
                rtimage = [];
                return;
            end
            list = this.rtimageForPlan(planUid);
            rtimage = RtImage();
            for i = 1:length(list)
                rtimage(i) = this.getDicomModalityObject(list(i).sopInstanceUid);
            end
        end
        
        function rtstruct = getRtStructForPlan(this, planUid)
            if ~this.rtstructsForPlan.isKey(planUid)
                rtstruct = [];
                return;
            end
            rtstruct = this.getDicomModalityObject(this.rtstructsForPlan(planUid));
        end
        
        function ctScan = getCtScanForPlan(this, planUid)
            structUid = this.rtstructsForPlan(planUid);
            if ~this.ctSeriesForStruct.isKey(structUid)
                ctScan = [];
                return;
            end
            uids = this.treeUids(structUid); %assume struct and ct are in same study
            study = this.getStudyObject(uids.studyInstanceUid);
            series = study.getSeriesObject(this.ctSeriesForStruct(structUid));
            ctScan = CtScan(series.getDicomObjectArray);
        end
        
        function [plan, dose, struct, ct] = createPlanPackage(this, planLabel)
            planUid = this.getPlanUidForLabel(planLabel);
            if isempty(planUid)
                throw(MException('MATLAB:Patient:createPlanPackage', 'planLabel not found for patient'))
            end            
            plan = RtPlan(this.getDicomObject(planUid), []);
            dose = this.getRtDoseForPlan(planUid);
            struct = this.getRtStructForPlan(planUid);
            ct = this.getCtScanForPlan(planUid);
        end
        
        function dicomObj = getDicomObject(this, sopInstanceUid)
            series = this.getDicomObjectSeries(sopInstanceUid);
            dicomObj = series.getDicomObject(sopInstanceUid);
        end
        
        function dicomObj = getDicomModalityObject(this, sopInstanceUid)
            series = this.getDicomObjectSeries(sopInstanceUid);
            dicomObj = series.getModalityObject(sopInstanceUid);
        end
    end
    
    methods (Access = 'private')
        function this = createMappingStructures(this)
            this.studies = containers.Map;
            this.labelsForPlan = containers.Map;
            this.rtdoseForPlan = containers.Map;
            this.rtimageForPlan = containers.Map;
            this.rtstructsForPlan = containers.Map;
            this.ctSeriesForStruct = containers.Map;
            this.treeUids = containers.Map;
        end
        
        function this = parsePatientInfo(this, dicomObj)
            this.id = dicomObj.dicomHeader;
            this.lastname = dicomObj.dicomHeader;
            this.firstname = dicomObj.dicomHeader;
            this.gender = dicomObj.dicomHeader;
            this.dateOfBirth = dicomObj.dicomHeader;
            this.parsed = true;
        end
        
        function this = parseIdentifiers(this, dicomObj)
            this.treeUids(dicomObj.sopInstanceUid) = ReferenceUidSet(dicomObj);
            
            switch dicomObj.modality
                case 'rtplan'
                    this = this.addRtPlan(dicomObj);
                case 'rtstruct'
                    this = this.addRtStruct(dicomObj);
                case 'rtdose'
                    this = this.addRtDose(dicomObj);
                case 'rtimage'
                    this = this.addRtImage(dicomObj);
            end
        end
        
        function this = addRtPlan(this, dicomObj)
            rtplan = RtPlan(dicomObj, []);
            this.labelsForPlan(rtplan.sopInstanceUid) = rtplan.planLabel;
            this.rtstructsForPlan(rtplan.sopInstanceUid) = rtplan.rtStructReferenceUid;
        end
        
        function this = addRtDose(this, dicomObj)
            rtdose = RtDose(dicomObj, []);
            
            if this.rtdoseForPlan.isKey(rtdose.referencedRtPlanUid)
                uidList = this.rtdoseForPlan(rtdose.referencedRtPlanUid);
                uidList(length(uidList)+1) = ReferenceUidSet(rtdose);
                this.rtdoseForPlan(rtdose.referencedRtPlanUid) = uidList;
            else
                this.rtdoseForPlan(rtdose.referencedRtPlanUid) = ReferenceUidSet(rtdose);
            end
        end
        
        function this = addRtStruct(this, dicomObj)
            rtstruct = RtStruct(dicomObj, []);
            this.ctSeriesForStruct(rtstruct.sopInstanceUid) = rtstruct.referencedImageSeriesUid;
        end
        
        function this = addRtImage(this, dicomObj)
            rtimage = RtImage(dicomObj, []);
            if this.rtimageForPlan.isKey(rtimage.referencedRtPlanUid)
                uidList = this.rtimageForPlan(rtimage.referencedRtPlanUid);
                uidList(length(uidList)+1) = ReferenceUidSet(rtimage);
                this.rtimageForPlan(rtimage.referencedRtPlanUid) = uidList;
            else
                this.rtimageForPlan(rtimage.referencedRtPlanUid) = ReferenceUidSet(rtimage);
            end
        end
        
        function uid = getPlanUidForLabel(this, label)
            uid = [];
            keys = this.labelsForPlan.keys;
            for i = 1:this.labelsForPlan.Count
                if strcmp(label, this.labelsForPlan(keys{i}))
                    uid = keys{i};
                    break;
                end
            end 
        end

        function series = getDicomObjectSeries(this, sopInstanceUid)
            uids = this.treeUids(sopInstanceUid);
            study = this.getStudyObject(uids.studyInstanceUid);
            series = study.getSeriesObject(uids.seriesInstanceUid);
        end
    end
end