%% Example script to show how awesome this codebase is.
% addpath('..\..\DicomUtilitiesMatlab');
addpath(genpath('.\HierarchyStructure'));
addpath(genpath('.\ModalityStructure'));

databaseMode = false;
%% load the files we need
disp('Loading CT, RTSTRUCT, DOSE and PLAN')
if databaseMode
    patientId = '12345';
    planId = '1p1b1d1a';
    myDicomFiles = DicomDatabase('D:\TestData\12345_java');
    [plan, dose, struct, ctScan] = createPlanPackage(myDicomFiles.getPatientObject(patientId), planId);
else
    plan = RtPlan('D:\TestData\12345_java\RTPLAN\FO-3630512758406762316.dcm', false);
    dose = RtDose('D:\TestData\12345_java\RTDOSE\FO-3153671375338877408_v2.dcm', false);
    struct = RtStruct('D:\TestData\12345_java\RTSTRUCT\FO-4073997332899944647.dcm', true);
    ctScan = CtScan('D:\TestData\12345_java\CT', false);
end
refImage = createImageFromCt(ctScan, false);
doseImage = createImageFromRtDose(dose);
refDose = matchImageRepresentation(doseImage, refImage);

%% create the objects required to calculate
% lungL = createContour(struct, 'Lung_L'); 
% lungR = createContour(struct, 'Lung_R');
% 
% voiLung = createVolumeOfInterest(lungR, refImage) + createVolumeOfInterest(lungL, refImage);

% disp('Creating GTV1 bitmask')
gtv1 = createContour(struct, 'GTV-1');
gtv1Voi = createVolumeOfInterest(gtv1, refImage);
gtv1Dose = createImageDataForVoi(gtv1Voi, refDose);
% 
% disp('Creating GTV1 bitmask on dose grid')
% gtv1VoiOnDoseGrid = createVolumeOfInterest(gtv1, doseImage);
% gtv1DoseOnDoseGrid = createImageDataForVoi(gtv1VoiOnDoseGrid, doseImage);
% 
% disp('Creating Body bitmask')
% body = createContour(struct, 'Body');
% bodyVoi = createVolumeOfInterest(body, refImage);
% bodyDose = createImageDataForVoi(bodyVoi, refDose);


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
