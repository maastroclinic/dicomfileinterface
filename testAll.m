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

testImageInstance = testImage();
resultImage= testImageInstance.run();

matlabResult = [resultCt,...
                   resultCalcGrid, ...
                   resultDose,...
                   resultStruct,...
                   resultImage] %#ok<NOPTS> suppress because i want to show result on cmd