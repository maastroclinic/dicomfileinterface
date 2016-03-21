classdef RtDose
    %RTDOSE object creates a 3D representation of the delivered Dose to the
    %patient on the grid defined by CtProperties.Axis
    
    properties (SetAccess  = 'private', GetAccess = 'public')
        fittedDoseCube;
        calcGrid;
    end
    
    methods
        
        function me = RtDose(dose, grid)
            me = me.parseRTDose(dose, grid);
        end
    end
    
    methods (Access = private)
        
        function me = parseRTDose(me, dose, grid)
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

                    me.calcGrid = grid;
                    me.fittedDoseCube = VolumeResample(squeeze(RTDose.Image), ...
                                                    RTDose.X, ...
                                                    RTDose.Y, ...
                                                    RTDose.Z, ...
                                                    grid.Axisi, ...
                                                    grid.Axisj, ...
                                                    grid.Axisk);
                else
                    throw(MException('RtDose:ErrorRescalingDose', 'Loaded RTDOSE file is not a valid 3D Dose'));
                end
            else
                throw(MException('RtDose:ErrorRescalingDose', 'Loaded RTDOSE does not have required field Is3DDoseMap'));
            end                           
        end        
    end
end

