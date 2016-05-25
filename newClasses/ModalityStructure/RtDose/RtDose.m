classdef RtDose < DicomObj
    %RTDOSE 
    
    properties      
        is3dDose
        is2dDose
        isDvh
        coordinateSystem
        
        doseGridScaling
        doseUnits
        doseType
        doseSummationType
        planId
        numberOfFrames
        originX
        originY
        originZ
        gridFrameOffsetVector
        referencedRtPlanUid
        beam
        fraction
        scaledImageData
    end
    
    methods
        function this = RtDose(varargin)
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            
            this = constructorParser(this, 'rtdose', varargin{1}, varargin{2});
        end
        
        %overwrite function to add image permutation.
        function this = readDicomData(this)
            this = readDicomData@DicomObj(this);
            this.pixelData(:,:,:,:) = this.pixelData(end:-1:1,:,:,:);
            this.pixelData = permute(this.pixelData,[2 4 3 1]);
            this.scaledImageData = this.pixelData .* this.doseGridScaling;
        end
        
        function out = get.referencedRtPlanUid(this)
            out = [];
            if isfield(this.dicomHeader, 'ReferencedRTPlanSequence')
                out = this.dicomHeader.ReferencedRTPlanSequence.Item_1.ReferencedSOPInstanceUID;
            end            
        end
        
        function out = get.is3dDose(this)
            out = false;
            if isfield(this.dicomHeader, 'NumberOfFrames') && ~isempty(this.dicomHeader.NumberOfFrames)
                out = true;
            end
        end
        
        function out = get.is2dDose(this)
            out = false;
            if isfield(this.dicomHeader, 'DoseSummationType')&&...
                 (strcmpi(this.dicomHeader.DoseSummationType,'beam'))
                out = true;
            end
        end
        
        function out = get.isDvh(this)
            out = false;
            if isfield(this.dicomHeader,'DVHSequence')
                out = true;
            end
        end
        
        %because we do not support 2D images, the system is always i
        %should be implemented when added 2D (multiframe) support
        function out = get.coordinateSystem(~)
            out = 'i';
        end
        
        function out = get.doseGridScaling(this)
            out = [];
            if isfield(this.dicomHeader, 'DoseGridScaling')
                out = this.dicomHeader.DoseGridScaling;
            end
        end
        
        function out = get.doseUnits(this)
            out = [];
            if isfield(this.dicomHeader, 'DoseUnits')
                out = lower(this.dicomHeader.DoseUnits);
            end
        end
        
        function out = get.doseType(this)
            out = [];
            if isfield(this.dicomHeader, 'DoseType')
                out = lower(this.dicomHeader.DoseType);
            end
        end
        
        function out = get.doseSummationType(this)
            out = [];
            if isfield(this.dicomHeader, 'DoseSummationType')
                out = lower(this.dicomHeader.DoseSummationType);
            end
        end
        
        function out = get.planId(this)
            out = [];
            if isfield(this.dicomHeader, 'SeriesDescription')
                out = lower(this.dicomHeader.SeriesDescription);
            end
        end
        
        function out = get.numberOfFrames(this)
            out = [];
            if isfield(this.dicomHeader, 'NumberOfFrames')
                out = lower(this.dicomHeader.NumberOfFrames);
            end
        end
        
        function out = get.beam(this)
            out = [];
            if isfield(this.dicomHeader, 'ReferencedRTPlanSequence')
                out = this.dicomHeader.ReferencedRTPlanSequence.Item_1.ReferencedFractionGroupSequence.Item_1.ReferencedBeamSequence.Item_1.ReferencedBeamNumber;
            elseif isfield(this.dicomHeader, 'InstanceNumber')
                %awesome DGRT logic, don't blame me.
                iNumb = num2str(this.dicomHeader.InstanceNumber);
                if iNumb>=3
                    out = str2double(iNumb(1:end-2));
                end
            end
        end
        
        function out = get.fraction(this)
            out = [];
            if isfield(this.dicomHeader, 'SeriesNumber')
                out = lower(this.dicomHeader.SeriesNumber);
            end
        end
        
        function out = get.originX(this)
            if this.imageOrientationPatient(1) == 1
                out = this.x;
            elseif this.imageOrientationPatient(1) == -1
                out = this.x - ...
                        (this.pixelSpacing(1) * this.columns);
            else
                out = [];
                warning('unsupported ImageOrientationPatient detected, cannot provide origin');
            end
        end
        
        function out = get.originY(this)
            out = this.y;
        end
        
        function out = get.originZ(this)
            if this.imageOrientationPatient(5) == -1
                out = -this.z;
            elseif this.imageOrientationPatient(5) == 1
                out = -this.z - ...
                        (this.pixelSpacing(2) * (this.rows - 1));
            else
                out = [];
                warning('unsupported ImageOrientationPatient detected, cannot provide origin');
            end 
        end
        
        function out = get.gridFrameOffsetVector(this)
            out = this.dicomHeader.GridFrameOffsetVector'/10;
        end        
    end
end