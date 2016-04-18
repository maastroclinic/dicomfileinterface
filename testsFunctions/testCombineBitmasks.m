classdef testCombineBitmasks < matlab.unittest.TestCase
    %TESTLIBRARYFUNCTIONS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fullImage
        oneThird
        oneThirdInverse
        twoThird
        twoThirdInverse
        secondThird
        smallerImage
    end
    
    methods (TestClassSetup)
        function setupOnce(me)
            me.fullImage = true(10,9,10);
            me.oneThird = false(10,9,10);
            me.oneThird(:,1:3,:) = 1;
            me.oneThirdInverse = ~me.oneThird;
            me.twoThird = false(10,9,10);
            me.twoThird(:,1:6,:) = 1;
            me.secondThird = false(10,9,10);
            me.secondThird(:,4:6,:) = 1;
            me.twoThirdInverse = ~me.twoThird;
            me.smallerImage = false(3,3,3);
        end
    end
    
    methods (Test)
        function testCombineTwoBitmasksPlus(me)
            [combinedMask] = combineBitmasks({me.oneThird, me.oneThirdInverse}, {'+'} );
            verifyEqual(me, combinedMask, me.fullImage);
            
            [combinedMask] = combineBitmasks({me.oneThird, me.secondThird}, {'plus'} );
            verifyEqual(me, combinedMask, me.twoThird);
        end
        
        function testCombineTwoBitmasksMinus(me)
            [combinedMask] = combineBitmasks({me.fullImage, me.twoThird}, {'-'} );
            verifyEqual(me, combinedMask, me.twoThirdInverse);
            
            [combinedMask] = combineBitmasks({me.twoThird, me.secondThird}, {'minus'} );
            verifyEqual(me, combinedMask, me.oneThird);
        end
        
        function testCombineThreeBitmasks(me)
            [combinedMask] = combineBitmasks({me.fullImage, me.oneThird, me.secondThird}, {'-', '-'} );
            verifyEqual(me, combinedMask, me.twoThirdInverse);
            
            [combinedMask] = combineBitmasks({me.oneThird, me.secondThird, me.twoThirdInverse}, {'plus', 'plus'} );
            verifyEqual(me, combinedMask, me.fullImage);
        end
        
        function testWrongInputTypes(me)
            try
                combineBitmasks('', []);
            catch EM
                verifyEqual(me, 'combineBitmasks:InputContainerMismatch', EM.identifier);
            end
            
            try
                combineBitmasks({''}, []);
            catch EM
                verifyEqual(me, 'combineBitmasks:InputTypeMismatch', EM.identifier);
            end
            
            try
                combineBitmasks({true}, 1);
            catch EM
                verifyEqual(me, 'combineBitmasks:InputContainerMismatch', EM.identifier);
            end
            
            try
                combineBitmasks({true}, {1});
            catch EM
                verifyEqual(me, 'combineBitmasks:InputTypeMismatch', EM.identifier);
            end
            
            try
                combineBitmasks({true}, {''});
            catch EM
                verifyEqual(me, 'combineBitmasks:InputDimensionMismatch', EM.identifier);
            end
        end        
    end
    
end

