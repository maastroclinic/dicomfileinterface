classdef DoseVolumeHistogram
    properties
        prescribedDose
        volume
        binsize
        vVolume
        vDose
        doseSamples
        vVolumeRelative
        vDoseRelative
    end
    
    methods
        function this = DoseVolumeHistogram(image, binsize)
            if nargin == 0
                return;
            end
            
            this = this.parseImage(image, binsize);
            this.binsize = binsize;
            this.volume = image.volume;
        end
        
        function this = parseImage(this, image, binsize)
            if ~isnumeric(binsize) && length(binsize) == 1
                throw(MException('DoseVolumeHistogram:parseImage','binsize should be single numeric value'));
            end
            
            dose = image.pixelData(~isnan(image.pixelData));
            sortedDose = sort(dose(:), 'ascend');
            
            %sortedDose = sort([0; doseCube(:)], 'ascend');
            %very hard because this is a physics thing, but in my theoretical unit test
            % the 0 resulted in an error, because an addition voxel is created.
            % want to leave this in for documentation purposes!
            
            this.vDose   = (0:binsize:(sortedDose(end)+binsize));
            this.vVolume = zeros(length(this.vDose),1);
            
            voxelCount = 0;
            for i = this.doseSamples:-1:1
                newVoxelList = find(sortedDose >= this.vDose(i));
                voxelCount = voxelCount + (length(newVoxelList));
                this.vVolume(i) = voxelCount;
                sortedDose(newVoxelList) = [];
            end
            this.vVolume = this.vVolume .* (image.pixelSpacingX*image.pixelSpacingY*image.pixelSpacingZ);
        end
        
        function out = get.doseSamples(this)
            out = length(this.vDose);
        end
        
        function this = set.prescribedDose(this, dose)
            if ~isnumeric(dose) && length(dose) == 1
                throw(MException('DoseVolumeHistogram:prescribedDose','prescribedDose should be single numeric value'));
            end
            this.prescribedDose = dose;
        end
        
        function this = set.volume(this, volume)
            if ~isnumeric(volume) && length(volume) == 1
                throw(MException('DoseVolumeHistogram:prescribedDose','prescribedDose should be single numeric value'));
            end
            this.volume = volume;
        end
        
        function out = get.vVolumeRelative(this)
            out = [];
            if ~isempty(this.volume)
                out = (this.vVolume / this.volume) * 100;
            end
        end
        
        function out = get.vDoseRelative(this)
            out = [];
            if ~isempty(this.prescribedDose)
                out = (this.vDose / this.prescribedDose) * 100;
            end
        end
    end
end