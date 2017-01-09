classdef RtPlan < DicomObj
    %RTPLAN represents a RtPlan DicomObj
    %
    %CONSTRUCTOR:
    % this = RtPlan(dicomItem, useVrHeuristics) creates a RtPlan object
    %  using the full file path (or a DicomObj) and boolean to deterine the use of VR Heuristics
    %
    % See also: DICOMOBJ
    
    properties
        planLabel
        rtStructReferenceUid
        targetPrescriptionDose
    end
    
    methods
        function this = RtPlan(dicomItem, useVrHeuristics)
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            
            this = constructorParser(this, 'rtplan', dicomItem, useVrHeuristics);
        end
        
        function readDicomData(~)
        %READDICOMDATA is overwritten for RTPLAN because RTPLANS do not contain pixel data, just
        % header info.
            warning('this standard dicom function is overwritten because the rtstruct dicom object does not contain an image block');
        end
        % -------- START GETTERS/SETTERS ----------------------------------
        function out = get.planLabel(this)
            out = this.dicomHeader.RTPlanLabel; 
        end
        
        function out = get.rtStructReferenceUid(this)
            out = [];
            if isfield(this.dicomHeader, 'ReferencedStructureSetSequence')
                out = this.dicomHeader.ReferencedStructureSetSequence.Item_1.ReferencedSOPInstanceUID;
            end
        end
        
        function out = get.targetPrescriptionDose(this)
            out = [];
            if isfield(this.dicomHeader, 'DoseReferenceSequence')
                if isfield(this.dicomHeader.DoseReferenceSequence.Item_1, 'TargetPrescriptionDose')
                    out = this.dicomHeader.DoseReferenceSequence.Item_1.TargetPrescriptionDose;
                elseif isfield(this.dicomHeader.DoseReferenceSequence.Item_1, 'DeliveryMaximumDose')
                    out = this.dicomHeader.DoseReferenceSequence.Item_1.DeliveryMaximumDose;
                end
            elseif isfield(this.dicomHeader, 'FractionGroupSequence')
                out = 0;
                fractionItems = fieldnames(this.dicomHeader.FractionGroupSequence);
                for i = 1:length(fractionItems)
                    beamItems = fieldnames(this.dicomHeader.FractionGroupSequence.(fractionItems{i}).ReferencedBeamSequence);
                    for j = 1:length(beamItems)
                        if isfield(this.dicomHeader.FractionGroupSequence.(fractionItems{i}).ReferencedBeamSequence.(beamItems{j}), 'BeamDose')
                            out = out + ...
                                (this.dicomHeader.FractionGroupSequence.(fractionItems{i}).ReferencedBeamSequence.(beamItems{j}).BeamDose* ...
                                 this.dicomHeader.FractionGroupSequence.(fractionItems{i}).NumberOfFractionsPlanned);
                        end
                    end
                end
                
                if out == 0;
                    out = [];
                end
            end
        end
    end
    
end

