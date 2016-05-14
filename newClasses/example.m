%% Example script to show how awesome this codebase is.


%% load the files we need
struct = RtStruct('D:\TestData\12345\RTSTRUCT\FO-4073997332899944647.dcm', true);
dose = RtDose('D:\TestData\12345\RTDOSE\FO-3153671375338877408_v2.dcm', false);
ctScan = CtScan('D:\TestData\12345\CT', false, '*.dcm');
plan = RtPlan('D:\TestData\12345\RTPLAN\FO-3630512758406762316.dcm', false);

%% create the objects required to calculate
gtv1 = createContour(struct, 'GTV-1');
referenceImage = createImageFromCt(ctScan, false);
bitmaskImage = createBitmask(gtv1, referenceImage);
%% calculate some reference values
