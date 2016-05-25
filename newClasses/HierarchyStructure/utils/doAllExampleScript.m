
% folder = 'R:\Projects\Valid Big Data\DICOM\20160524';
folder = 'D:\TestData\DicomDatabase';
targetFolder = 'D:\TestData\Results';

loopOverPatientDirs();
createListOfCompletePatientsAndPlans();

createCsvForData(data, fullfile(targetFolder, 'myFiles.csv'));
moveDataToNewFolder(data, targetFolder);
