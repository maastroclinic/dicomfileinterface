%% Example script to show how awesome this codebase is.


%% load the files we need
tic
disp('Loading CT, RTSTRUCT, DOSE and PLAN')
patientId = '12345';
planId = '1p1b1d1a';
myDicomFiles = DicomDatabase('D:\TestData\12345_java');
[plan, dose, struct, ctScan] = createPlanPackage(myDicomFiles.getPatientObject(patientId), planId);
referenceImage = createImageFromCt(ctScan, false);
% doseImage = createDoseImage(dose, referenceImage);
toc

%% create the objects required to calculate
tic
disp('Creating GTV1 bitmask')
gtv1 = createContour(struct, 'GTV-1');
gtv1Voi = createBitmask(gtv1, referenceImage);
toc
% tic
% disp('Applying dose to bitmask')
% bitmaskedDoseImage = applyBitmaskToImage(doseImage, bitmaskVoi);
% toc

tic
disp('Creating Body bitmask')
body = createContour(struct, 'Body');
bodyVoi = createBitmask(body, referenceImage);
toc
% tic
% disp('Applying dose to bitmask')
% bitmaskedDoseImage = applyBitmaskToImage(doseImage, bitmaskVoi);
% toc


%% calculate some reference values