classdef PlanReferenceObjects
    %PLANREFERENCEOBJECTS [please add info on me here :<]
    
    properties
        planUids
        planLabels
        labelsForPlan
        rtdoseForPlan
        rtimageForPlan
        rtstructsForPlan
        ctSeriesForStruct
        refUids
    end
    
    methods
        function this = PlanReferenceObjects()
            this = this.createMappingStructures();
            if nargin == 0
                return;
            end
        end    
        
        function this = parseDicomObject(this, dicomObj)
            this.refUids(dicomObj.sopInstanceUid) = ReferenceUidSet(dicomObj);
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
        
        function out = get.planUids(this)
            out = this.labelsForPlan.keys;
        end
        
        function out = get.planLabels(this)
            out = this.labelsForPlan.values;
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
    end
    
    methods (Access = 'private')
        function this = createMappingStructures(this)
            this.rtdoseForPlan = containers.Map;
            this.rtimageForPlan = containers.Map;
            this.labelsForPlan = containers.Map;
            this.rtstructsForPlan = containers.Map;
            this.ctSeriesForStruct = containers.Map;
            this.refUids = containers.Map;
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
    end
end