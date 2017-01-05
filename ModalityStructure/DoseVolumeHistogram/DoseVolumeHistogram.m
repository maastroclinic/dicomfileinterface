classdef DoseVolumeHistogram
% DOSEVOLUMEHISTOGRAM converts the data of a VolumeOfInterest clipped dose Image to a sampled
%  DoseVolumeHistogram
%
% CONSTRUCTOR
%  this = DoseVolumeHistogram(image, binsize) samples an image object with the size of binsize
%
% See also: VOLUMEOFINTEREST, CALCULATEDVHD, CALCULATEDVHV, CREATEDOSEVOLUMEHISTOGRAMDTO,
% CREATEDOSEVOLUMEHISTOGRAMFROMDTO
    properties
        prescribedDose
        volume
        binsize
        vVolume
        vDose
        doseSamples
        vVolumeRelative
        vDoseRelative
        
        minDose
        meanDose
        maxDose
    end
    
    methods
        function this = DoseVolumeHistogram(image, binsize)
            if nargin == 0
                return;
            end
            
            this = this.parseImage(image, binsize);
        end
        
        function this = parseImage(this, image, binsize)
        %PARSEIMAGE(image, binsize) converts a provided dose image to a DoseVolumeHistogram
        % in the provided binsize.
            if ~isnumeric(binsize) && length(binsize) == 1
                throw(MException('DoseVolumeHistogram:parseImage','binsize should be single numeric value'));
            end
            
            dose = image.pixelData(~isnan(image.pixelData));
            sortedDose = sort(dose(:), 'ascend');
            
            %sortedDose = sort([0; doseCube(:)], 'ascend');
            %very hard because this is a physics thing, but in my theoretical unit test
            % the 0 resulted in an error, because an addition voxel is created.
            % want to leave this in for documentation purposes!
            
            this.vDose   = (0:binsize:(sortedDose(size(sortedDose,1))+binsize));

            vHistogram = histcounts (dose, this.vDose,'Normalization', 'cumcount');
            vHistogram = [0, vHistogram]; %need to ad a leading 0 to make sure the vector is alligned with the dose vector
            this.vVolume = abs(vHistogram - max(vHistogram)); % Inverse
            this.vVolume = this.vVolume.*(image.pixelSpacingX*image.pixelSpacingY*image.pixelSpacingZ);
            
            this.binsize = binsize;
            this.minDose = nanmin(image.pixelData(:));
            this.meanDose = nanmean(image.pixelData(:));
            this.maxDose = nanmax(image.pixelData(:));
            this.volume = image.volume;
        end
        
        % -------- START GETTERS/SETTERS ----------------------------------
        function out = get.doseSamples(this)
            out = length(this.vDose);
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
    end
end