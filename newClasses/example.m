%% Example script to show how awesome this codebase is.


%% load the files we need
tic
disp('Loading CT, RTSTRUCT, DOSE and PLAN')
myDicomFiles = DicomDatabase('D:\TestData\12345_java');


struct = RtStruct('D:\TestData\12345\RTSTRUCT\FO-4073997332899944647.dcm', true);
dose = RtDose('D:\TestData\12345\RTDOSE\FO-3153671375338877408_v2.dcm', false);
ctScan = CtScan('D:\TestData\12345\CT', false, '*.dcm');
plan = RtPlan('D:\TestData\12345\RTPLAN\FO-3630512758406762316.dcm', false);
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