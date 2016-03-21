classdef RoiDose < RtVolume
    % RTVOLUME calculates volume, volume with a certain dose, as well 
    % as mean, max and min dose for a volume based on DICOM information    
    methods
        function me = RoiDose(name, varargin)
            me.volume = NaN;
            me = me.setName(name);
            
            [i_calc, i_rtdose, i_rtstruct] = me.parseVargarin(varargin);
            
            if isempty(i_calc)
                return;
            end
            
            me = me.setcalcGrid(varargin{i_calc});
            if ~isempty(i_rtstruct)
                me = me.parseRtStruct(varargin{i_rtstruct}, name);
                if ~isempty(i_rtdose)
                    me = me.parseRtDose(varargin{i_rtdose});
                end
                me = me.compress();
            end
        end
               
        function me = addRtDose(me, dose)
            me = me.parseRtDose(dose);
        end
        
        function out = dose(me, operation)
            % DOSE Calculate minimum, maximum or mean dose for this structure
            if me.canCalculateRoiValues
                switch strtrim(lower(operation))
                    case 'mean'
                        out = nanmean(me.roiValues(:));
                    case 'max'
                        out = nanmax(me.roiValues(:));
                    case 'min'
                        out = nanmin(me.roiValues(:));
                    otherwise
                        out = NaN;
                end
            else
                out = NaN;
            end
        end
        
        % DVH info:
        %   Over the last decade, three dimensional radiation therapy planning 
        %   has enabled a detailed analysis of what now is commonly known as V20
        %   which is the percentage of the lung volume (with subtraction of the 
        %   volume involved by lung cancer) which receives radiation doses of 20 Gy
        %   or more. Over the last decade, three dimensional radiation therapy 
        %   planning has enabled a detailed analysis of what now is commonly known 
        %   as V20 
        % SOURCE http://cancergrace.org/radiation/2012/02/18/v20/
        function out = volumeWithDoseOf(me, doseLimit)
            % VOLUMEWITHDOSEOF Calculate the volume (in cc) of the structure with at least a dose above
            % or equal to the specified dose
            if me.canCalculateRoiValues
                out = length(find(me.roiValues(:) >= doseLimit)) * prod(me.calcGrid.PixelSpacing);
            else
                out = NaN;
            end
        end
        
        function out = volumePercentageWithDoseOf(me, doseLimit)
            % VOLUMEPRECENTAGEWITHDOSEOF Calculate the volume (in %) of the structure with at least a dose above
            % or equal to the specified dose
            out = me.volumeWithDoseOf(doseLimit)/ me.volume * 100;
        end
        
        %DVH info:
        % the dose to 95% of the considered volume (D95) 
        % SOURCE: http://ro-journal.biomedcentral.com/articles/10.1186/1748-717X-4-44
        % volumeLimit(cc), out(Gy)
        function out = doseToCertainVolume(me, volumeLimit)
            if me.canCalculateRoiValues
                %max value is added 2 times at beginning, because zero is
                %added before dose vector
                doseMatrix  = me.roiValues(~isnan(me.roiValues));
                doseVect    = sort([0; doseMatrix(:)], 'ascend');
                volumeVect  = [me.volume, me.volume:-prod(me.calcGrid.PixelSpacing):prod(me.calcGrid.PixelSpacing)];
                out         = doseVect(find(volumeVect <= volumeLimit, 1,'first'));
                %take the first one because they all have the dose criteria
            else
                out = NaN;
            end
        end
        
        % volumeLimit(%), out(Gy)
        function out = doseToCertainVolumePercentage(me, volumeLimit)
            volumeLimitPercentage = me.volume*(volumeLimit/100);
            out = me.doseToCertainVolume(volumeLimitPercentage);
        end
        
        % volumeLimit(%), out(%)
        function out = dosePercentageToCertainVolumePercentage(me, volumeLimit, targetPrescription)
            out = me.doseToCertainVolumePercentage(volumeLimit);
            out = (out/targetPrescription)*100;
        end
        
        % volumeLimit(cc), out(%)
        function out = dosePercentageToCertainVolume(me, volumeLimit, targetPrescription)
            out = me.doseToCertainVolume(volumeLimit);
            out = (out/targetPrescription)*100;
        end
        
        %binSize is double in Gy
        function [DVHVolumeVect, DVHDoseVect] = exportDoseVolumeHistogramAbsolute(me, binSize)
            doseMatrix = me.roiValues(~isnan(me.roiValues));
            doseVect = sort([0; doseMatrix(:)], 'ascend');
            DVHDoseVect   = (0:binSize:max(max(max(me.roiValues)))+binSize);
            DVHVolumeVect = zeros(length(DVHDoseVect),1);
            
            for i = 1 : length(DVHDoseVect)
                tmp              = find(doseVect >= DVHDoseVect(i));
                DVHVolumeVect(i) = (length(tmp)*prod(me.calcGrid.PixelSpacing));
            end
        end
        
        %binSize is double in Gy
        function [DVHVolumeVect, DVHDoseVect] = exportDoseVolumeHistogram(me, binSize)
            [DVHVolumeVect, DVHDoseVect] = me.exportDoseVolumeHistogramAbsolute(binSize);
            DVHVolumeVect = (DVHVolumeVect /(me.volume))*100;
        end
    end
    
    methods (Access = private)
        
        function me = parseRtDose(me, dose)
            if ~me.hasFittedRoiValues
                if me.calcGrid == dose.calcGrid
                    me.hasFittedRoiValues = true;
                    me.roiValues = me.calculateRoiValues(dose.fittedDoseCube);
                else
                    throw(MException('RtVolume:DimensionMismatch', 'RtDose does not match RtVolume calcGrid'));
                end
            else
                throw(MException('RtVolume:rtDoseOverwrite', 'This rtVolume already has a fitted dose, cannot overwrite.'));
            end
        end
        
    end
end