%% Example script to show how awesome this codebase is.
% addpath('..\..\DicomUtilitiesMatlab');
addpath(genpath('.\HierarchyStructure'));
addpath(genpath('.\ModalityStructure'));
addpath('jsonlab');
tic
databaseMode = false;
%% load the files we need
disp('Loading CT, RTSTRUCT, DOSE and PLAN')
if databaseMode
    patientId = '12345';
    planId = '1p1b1d1a';
    myDicomFiles = DicomDatabase('\\dev-build.maastro.nl\testdata\DIU\dicomutilitiesmatlab');
    [plan, dose, struct, ctScan] = createPlanPackage(myDicomFiles.getPatientObject(patientId), planId);
else
%     plan = RtPlan('D:\TestData\12345_java\RTPLAN\FO-3630512758406762316.dcm', false);
    dose = RtDose('\\dev-build.maastro.nl\testdata\DIU\dicomutilitiesmatlab\RTDOSE\FO-3153671375338877408_v2.dcm', false);
    struct = RtStruct('\\dev-build.maastro.nl\testdata\DIU\dicomutilitiesmatlab\RTSTRUCT\FO-4073997332899944647.dcm', true);
    ctScan = CtScan('\\dev-build.maastro.nl\testdata\DIU\dicomutilitiesmatlab\CT', false);
end
refImage = createImageFromCt(ctScan, false);
doseImage = createImageFromRtDose(dose);
refDose = matchImageRepresentation(doseImage, refImage);
toc
%% create the objects required to calculate
% lungL = createContour(struct, 'Lung_L'); 
% lungR = createContour(struct, 'Lung_R');
% 
% voiLung = createVolumeOfInterest(lungR, refImage) + createVolumeOfInterest(lungL, refImage);

% disp('Creating GTV1 bitmask')
tic
gtv1 = createContour(struct, 'GTV-1');
gtv1Voi = createVolumeOfInterest(gtv1, refImage);
gtv1Dose = createImageDataForVoi(gtv1Voi, refDose);
tic
gtv1Dvh = DoseVolumeHistogram(gtv1Dose, 0.001);
toc
% % 
% % disp('Creating GTV1 bitmask on dose grid')
% gtv1VoiOnDoseGrid = createVolumeOfInterest(gtv1, doseImage);
% gtv1DoseOnDoseGrid = createImageDataForVoi(gtv1VoiOnDoseGrid, doseImage);
% % 
% % disp('Creating Body bitmask')
tic
body = createContour(struct, 'Body');
bodyVoi = createVolumeOfInterest(body, refImage);
bodyDose = createImageDataForVoi(bodyVoi, refDose);
bodyDvh = DoseVolumeHistogram(bodyDose, 0.1);
toc

%% calculate some reference values
% image = gtv1Dose;
% for i = 1:size(image.pixelData,2) 
%     slice = squeeze(image.pixelData(:,i,:)); 
%     if (max(max(max(slice)))>0); 
%         figure; 
%         imagesc(slice); 
%     end 
% end
% 
% figure
% imagesc(squeeze(data(:,end,:)));
% figure
% imagesc(squeeze(DoseValues(:,end,:)));
