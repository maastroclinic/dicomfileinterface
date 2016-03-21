classdef testRoiImage < matlab.unittest.TestCase

    properties

        % Locations of test files
        BasePath = 'D:\TestData\12345'
        RTStructFile = '\FO-4073997332899944647.dcm';
        RTDoseFile   = '\FO-3153671375338877408_v2.dcm';
        
        % Results 
        add_later = [];
        
        relativeError = 0.0035;

        % Required for setup
        rtStruct;
        ct;
        calcGrid;
    end
    
    methods (TestClassSetup)
        function setupOnce(me)
            me.ct = Ct(fullfile(me.BasePath, 'CT'), 'folder', true);
            me.calcGrid = CalculationGrid(me.ct, 'ct');               
            me.rtStruct = RtStruct(fullfile(me.BasePath, 'RTSTRUCT' , me.RTStructFile), me.calcGrid);
       
        end
    end    
 
    methods(Test)
        
        function testCtVolumeGtv1(me)
            GtvCt = RoiImage('GTV-1', me.calcGrid, me.rtStruct, me.ct);
            verifyEqual(me, double(~isnan(GtvCt.roiValues)), GtvCt.bitmask);
        end
        
    end
end