classdef CalculationGrid
    %CALCULATIONGRID The image modality defines the grid on which calculations can
    %be performed. It also stores the information for the rescaling
    %function of a instance of RtVolume.
    
    properties (SetAccess  = 'private', GetAccess = 'public')
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
        
        PRECISION = 10^-6;
        hasAllProperties = false;
    end
    
    methods
        function me = CalculationGrid(in, type)
            %TODO add other image modalities
            switch type
                case 'ct'
                    me = me.createCalculationGrid(in);
                case 'java'
                    me = me.parseJavaProperties(in);
                otherwise
                    throw(MException('Ct:InvalidInput', ...
                            'Please consult the documentation for valid inputs'));
            end
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
        
        function out = eq(a,b)
            out = true;
            
            if a.hasAllProperties ~= b.hasAllProperties || ...
                    ~equalDoubleArray(a.Origin, b.Origin, a.PRECISION) || ...
                    ~equalDoubleArray(a.Dimensions, b.Dimensions, a.PRECISION) || ...
                    ~equalDoubleArray(a.Axisi, b.Axisi, a.PRECISION) || ...
                    ~equalDoubleArray(a.Axisj, b.Axisj, a.PRECISION) || ...
                    ~equalDoubleArray(a.Axisk, b.Axisk, a.PRECISION) || ...
                    ~equalDoubleArray(a.PixelSpacingi, b.PixelSpacingi, a.PRECISION) || ...
                    ~equalDoubleArray(a.PixelSpacingj, b.PixelSpacingj, a.PRECISION) || ...
                    ~equalDoubleArray(a.PixelSpacingk, b.PixelSpacingk, a.PRECISION) 
                out = false;
            end            
        end
        
   
    end
    
    methods (Access  = private) 
        function me = createCalculationGrid(me, prop)
            me.PixelSpacing = [double(prop.PixelSpacing(1)) double(prop.SliceThickness) double(prop.PixelSpacing(2))] / 10;
            me.Origin = [0 0 0];
             
            % Define 3D grid dimensions
            % Note: explicitly cast to double as Matlab does this for
            % the other matrices automatically when they are divided
            % by 10 to convert to IEC coordinates.
            % If this is not done the calculations for me.Axis*() fail
            % with the following error:
            % Error using  :
            % Double operands interacting with integer operands must
            % have integer values.
            me.Dimensions = double([prop.Rows prop.CTFileLength prop.Columns]);

            if isequal(prop.ImageOrientationPatient, [ 1 ; 0 ; 0 ; 0 ; 1 ; 0 ])
                % Note: explicit conversion from logical to unint16 to
                % make this strange calculation possible, otherwise it
                % would error out with the following error:
                % Error using  .*
                % Integers can only be combined with integers of the
                % same class, or scalar doubles.

                me.Origin(1) = (prop.ImagePositionPatient(1)/10) - ...
                    (uint16(prop.ImageOrientationPatient(1)) == -1) * ...
                    (me.PixelSpacing(1) * me.Dimensions(1));
                me.Origin(2) = (prop.ImagePositionPatient(3) / 10);
                me.Origin(3) = (-prop.ImagePositionPatient(2) / 10) - ...
                    double(prop.ImageOrientationPatient(5)) * ...
                    (double(me.PixelSpacing(3)) * double(me.Dimensions(3) - 1));
            else
                throw(MException('ctProperties:unsupportedCalculationBox', ...
                        ['The ImagePositionPatient Tag of the Image Modality (' ...
                        num2str(prop.ImageOrientationPatient) ') is not ' ...
                        'supported by this toolbox. Cannot perform calculations.']));
            end

            me.Axisi = (me.Origin(1):me.PixelSpacing(1):me.Origin(1) + (me.Dimensions(1) - 1) * me.PixelSpacing(1))';
            me.Axisj = (me.Origin(2):me.PixelSpacing(2):me.Origin(2) + (me.Dimensions(2) - 1) * me.PixelSpacing(2))';
            me.Axisk = (me.Origin(3):me.PixelSpacing(3):me.Origin(3) + (me.Dimensions(3) - 1) * me.PixelSpacing(3))';

            me.hasAllProperties = true; 
        end
         
        function me = parseJavaProperties(me, prop)
            %Fail if one of the following properties is not present:
            %PixelSpacing, SliceThickness, Rows, Columns, length CT Files,
            %ImageOrientationPatient, ImagePositionPatient
            if ~isfield(prop, 'PixelSpacing')
                throw(MException('CtProperties:MissingParamater', 'CT property PixelSpacing was not specified'));
            elseif ~isfield(prop, 'SliceThickness')
                throw(MException('CtProperties:MissingParamater', 'CT SliceThickness Dimensions was not specified'));
            elseif ~isfield(prop, 'Rows')
                throw(MException('CtProperties:MissingParamater', 'CT property Rows was not specified'));
            elseif ~isfield(prop, 'Columns')
                throw(MException('CtProperties:MissingParamater', 'CT property Columns was not specified'));
            elseif ~isfield(prop, 'ImageOrientationPatient')
                throw(MException('CtProperties:MissingParamater', 'CT property ImageOrientationPatient was not specified'));
            elseif ~isfield(prop, 'CTFileLength')
                throw(MException('CtProperties:MissingParamater', 'CT property CTFileLength was not specified'));
            elseif ~isfield(prop, 'ImagePositionPatient')
                throw(MException('CtProperties:MissingParamater', 'CT property ImagePositionPatient was not specified'));
            end
            
            %transform ct values
            prop.ImageOrientationPatient = prop.ImageOrientationPatient';
            prop.ImagePositionPatient = prop.ImagePositionPatient';
            prop.PixelSpacing = prop.PixelSpacing';
            
            me = me.createCalculationGrid(prop);
        end
    end
end
