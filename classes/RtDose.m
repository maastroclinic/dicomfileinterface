classdef RtDose
    %RTDOSE object creates a 3D representation of the delivered Dose to the
    %patient on the grid defined by CtProperties.Axis
    
    properties (SetAccess  = 'private', GetAccess = 'public')
        fittedDoseCube;
        
        Origin;
        Dimensions;
        
        % i = lateral direction in image coordinate system
        % j = transversal direction in image coordinate system
        % k = axial direction in image coordinate system
        Axis;
        Axisi; 
        Axisj; 
        Axisk;
        
        PixelSpacing = [0,0,0];
        PixelSpacingi;
        PixelSpacingj;
        PixelSpacingk;
    end
    
    methods
        
        function me = RtDose(dose, pixelSpacing, Origin, Axis, Dimensions)
            me = me.parseRTDose(dose, pixelSpacing, Origin, Axis, Dimensions);
        end
        
        function out = get.PixelSpacingi(me)
            out = me.PixelSpacing(1);
        end
        
        function out = get.PixelSpacingj(me)
            out = me.PixelSpacing(2);
        end
        
        function out = get.PixelSpacingk(me)
            out = me.PixelSpacing(3);
        end
        
        function out = get.Axis(me)
            out.Axisi = me.Axisi;
            out.Axisj = me.Axisj;
            out.Axisk = me.Axisk;
        end 
    end
    
    methods (Access = private)
        
        function me = parseRTDose(me, dose, pixelSpacing, Origin, Axis, Dimensions)
            %check if it is filePath of DicomStruct
            if ~isfield(dose, 'DicomHeader')
                if ~exist(dose, 'file')
                    doseString = regexprep(dose,'\','\\\');
                    throw(MException('Matlab:FileNotFound', ['DICOM RT-DOSE file ''' doseString ''' not found.''']));
                end
                
                dose = read_dicomrtdose(dose);
            end
            
            
            
            if isfield(dose, 'Is3DDoseMap')
                if dose.Is3DDoseMap
                    % Perform some actions, as designed by B. Nijsten
                    RTDose = Generate3DGrid(dose,'',[],0);
                    RTDose.Image = dose.Image;

                    me = me.setPixelSpacing(pixelSpacing);
                    me = me.setOrigin(Origin);
                    me = me.setAxis(Axis);
                    me = me.setDimensions(Dimensions);
                    
                    me.fittedDoseCube = VolumeResample(squeeze(RTDose.Image), ...
                                                    RTDose.X, ...
                                                    RTDose.Y, ...
                                                    RTDose.Z, ...
                                                    me.Axisi, ...
                                                    me.Axisj, ...
                                                    me.Axisk);
                else
                    throw(MException('RtDose:ErrorRescalingDose', 'Loaded RTDOSE file is not a valid 3D Dose'));
                end
            else
                throw(MException('RtDose:ErrorRescalingDose', 'Loaded RTDOSE does not have required field Is3DDoseMap'));
            end                           
        end
        
        function me = setPixelSpacing(me, pixelSpacing)
            me.PixelSpacing = pixelSpacing;
        end
        
        function me = setOrigin(me, Origin)
            me.Origin = Origin;
        end
        
        function me = setDimensions(me, Dimensions)
            me.Dimensions = Dimensions;
        end

        function me = setAxis(me, Axis)
            me.Axisi = Axis.Axisi;
            me.Axisj = Axis.Axisj;
            me.Axisk = Axis.Axisk;
        end
    end
end

