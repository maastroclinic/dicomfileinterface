addpath(genpath('classes'));
addpath(genpath('dependencies'));
addpath(genpath('functionsJava'));
addpath(genpath('testsMatlab'));
addpath(genpath('testsJava'));
%ADD PATH TO DICOM UTILITIES MATLAB HERE!
% https://dev-git.maastro.nl/projects/DIU/repos/dicomutilitiesmatlab
addpath(genpath('..\DicomUtilitiesMatlab')); 


%% matlab tests
testCt = testCt();
resultCt = testCt.run();

testCalcGrid = testCalculationGrid();
resultCalcGrid = testCalcGrid.run();

testDose = testRtDose();
resultDose = testDose.run();

testStruct = testRtStruct();
resultStruct = testStruct.run();

testRoidose = testRoiDose();
resultRoidose = testRoidose.run();

testRoiimage = testRoiImage();
resultRoiimage = testRoiimage.run();

testClinCase = testClinicalCase();
resultClinCase = testClinCase.run();

matlabResult = [resultCt,...
                   resultCalcGrid, ...
                   resultDose,...
                   resultStruct,...
                   resultRoidose,...
                   resultRoiimage,...
                   resultClinCase] %#ok<NOPTS> suppress because i want to show result on cmd

%% java tests
testMatlabObjects = testCreateMatlabDicomObjects();
resultDicomObjects = testMatlabObjects.run();

testCombineRoi = testCreateCombinedRoiDose();
resultCombineRoi = testCombineRoi.run();

testCalcWrapper = testAllCalculationWrappers();
resultWrapper = testCalcWrapper.run();

javaResult = [resultDicomObjects, ...
                resultCombineRoi,...
                resultWrapper] %#ok<NOPTS> suppress because i want to show result on cmd

