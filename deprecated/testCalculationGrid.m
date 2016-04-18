classdef testCalculationGrid < matlab.unittest.TestCase
    
    properties
        % Locations of test files
        % BasePath should be the path to the folder containing the CT, RTSTRUCT and RTDOSE folders
        BasePath = 'D:\TestData\12345'
        %path to refAxis mat file
        refAxisPath = 'refAxis.mat';
        
        CONSTRUCTOR_JAVA = 'java';
        CONSTRUCTOR_CT = 'ct';
        javaCtProperties;
        ct;
        
        % verification values
        ORIGIN = [-24.9512  -68.5500   -8.3512];
        DIMENSIONS = [512   136   512];
        REF_AXIS;
        PERCISION = 0.0001;
    end
    
    methods (TestClassSetup)
        function setupOnce(me)
            %mock the java structure object
            me.javaCtProperties = mockJavaCtProperties(fullfile(me.BasePath, 'CT'));            
            me.ct = Ct(fullfile(me.BasePath, 'CT'), 'folder', false);
            
            load(fullfile(me.BasePath, me.refAxisPath));
            me.REF_AXIS = refAxis;
        end
    end    
    
    methods(Test)
        function testConstructorJavaProperties(me)
            calcGrid = CalculationGrid(me.javaCtProperties, me.CONSTRUCTOR_JAVA);
            verifyEqual(me, calcGrid.Origin, me.ORIGIN, 'AbsTol', me.PERCISION);
            verifyEqual(me, calcGrid.Dimensions, me.DIMENSIONS, 'AbsTol', me.PERCISION);
            verifyEqual(me, calcGrid.Axisi, me.REF_AXIS.Axisi, 'AbsTol', me.PERCISION);
            verifyEqual(me, calcGrid.Axisj, me.REF_AXIS.Axisj, 'AbsTol', me.PERCISION);
            verifyEqual(me, calcGrid.Axisk, me.REF_AXIS.Axisk, 'AbsTol', me.PERCISION);
        end
        
        function testConstructorFolder(me)           
            calcGrid = CalculationGrid(me.ct, me.CONSTRUCTOR_CT);
            verifyEqual(me, calcGrid.Origin, me.ORIGIN, 'AbsTol', me.PERCISION);
            verifyEqual(me, calcGrid.Dimensions, me.DIMENSIONS, 'AbsTol', me.PERCISION);
            verifyEqual(me, calcGrid.Axisi, me.REF_AXIS.Axisi, 'AbsTol', me.PERCISION);
            verifyEqual(me, calcGrid.Axisj, me.REF_AXIS.Axisj, 'AbsTol', me.PERCISION);
            verifyEqual(me, calcGrid.Axisk, me.REF_AXIS.Axisk, 'AbsTol', me.PERCISION);
        end
        
        function testCompareSame(me)
            java = CalculationGrid(me.javaCtProperties, me.CONSTRUCTOR_JAVA);
            matlab = CalculationGrid(me.ct, me.CONSTRUCTOR_CT);
            compare = java == matlab;
            verifyEqual(me, compare, true);
        end
        
        function testCompareDiffOrigin(me)
            errorProp = me.javaCtProperties;
            errorProp.ImagePositionPatient = errorProp.ImagePositionPatient - 10;
            java = CalculationGrid(errorProp, me.CONSTRUCTOR_JAVA);
            matlab = CalculationGrid(me.ct, me.CONSTRUCTOR_CT);
            compare = java == matlab;
            verifyEqual(me, compare, false);
        end
        
        function testCompareDiffDimensions(me)
            errorProp = me.javaCtProperties;
            errorProp.Rows = errorProp.Rows -10;
            java = CalculationGrid(errorProp, me.CONSTRUCTOR_JAVA);
            matlab = CalculationGrid(me.ct, me.CONSTRUCTOR_CT);
            compare = java == matlab;
            verifyEqual(me, compare, false);
        end
        
        function testCompareDiffAxis(me)
            errorProp = me.javaCtProperties;
            errorProp.ImagePositionPatient = errorProp.ImagePositionPatient - 10;
            java = CalculationGrid(errorProp, me.CONSTRUCTOR_JAVA);
            matlab = CalculationGrid(me.ct, me.CONSTRUCTOR_CT);
            compare = java == matlab;
            verifyEqual(me, compare, false);
        end
        
        function testCompareDiffPixelSpacing(me)
            errorProp = me.javaCtProperties;
            errorProp.PixelSpacing = errorProp.PixelSpacing ./ 2;
            java = CalculationGrid(errorProp, me.CONSTRUCTOR_JAVA);
            matlab = CalculationGrid(me.ct, me.CONSTRUCTOR_CT);
            compare = java == matlab;
            verifyEqual(me, compare, false);
        end
    end
    
end

