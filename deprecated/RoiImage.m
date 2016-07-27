classdef RoiImage < RtVolume
    
    methods
        function me = RoiImage(name, varargin)
            me.volume = NaN;
            me = me.setName(name);
            
            [i_calc, i_ct, i_rtstruct] = me.parseVargarin(varargin);
            
            if isempty(i_calc)
                return;
            end
            
            me = me.setcalcGrid(varargin{i_calc});
            if ~isempty(i_rtstruct)
                me = me.parseRtStruct(varargin{i_rtstruct}, name);
                if ~isempty(i_ct)
                    me = me.parseCt(varargin{i_ct});
                end
                me = me.compress();
            end
        end        
    end 
    
    methods (Access = private)
        function me = parseCt(me, ct)
            if ct.hasImageData
                if me.calcGrid == CalculationGrid(ct, 'ct')
                    me.hasFittedRoiValues = true;
                    me.roiValues = me.calculateRoiValues(ct.imageData);
                else
                    throw(MException('RtVolume:DimensionMismatch', 'Ct does not match RtVolume calcGrid'));
                end
            else
                throw(MException('Ct:NoImageData', 'This ct has no loaded image data.'));
            end
        end
    end
end

