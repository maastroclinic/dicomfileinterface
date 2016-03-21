% RTSTRUCT = 'D:\TestData\Nijmegen_pinnacle_voorbeelden\anon_dlra_1\RTSTRUCT\2.16.840.1.113669.2.931128.997687556.20150317121751.265439_0001_000000_14265910850112.dcm';
% RTDOSE = 'D:\TestData\Nijmegen_pinnacle_voorbeelden\anon_dlra_1\RTDOSE\2.16.840.1.113669.2.931128.997687556.20150317121751.265445_0001_000001_14265910860114.dcm';
% CT = 'D:\TestData\Nijmegen_pinnacle_voorbeelden\anon_dlra_1\CT\';

% RTSTRUCT = 'D:\TestData\Nijmegen_pinnacle_voorbeelden\anon_dlra_2\RTSTRUCT\2.16.840.1.113669.2.931128.997687556.20150317121552.943705_0000_000000_14265909650001.dcm';
% RTDOSE = 'D:\TestData\Nijmegen_pinnacle_voorbeelden\anon_dlra_2\RTDOSE\2.16.840.1.113669.2.931128.997687556.20150317121552.943712_0000_000001_14265909690003.dcm';
% CT = 'D:\TestData\Nijmegen_pinnacle_voorbeelden\anon_dlra_2\CT\';

RTSTRUCT = 'D:\TestData\12345\RTSTRUCT\FO-4073997332899944647.dcm';
RTDOSE   = 'D:\TestData\12345\RTDOSE\FO-3153671375338877408_v2.dcm';
CT       = 'D:\TestData\12345\CT\';

%set CT path
CTFiles = dir(fullfile(CT, '*dcm'));
%get ct header properties
header = dicominfo(fullfile(CT, CTFiles(1).name));
for j = 2:length(CTFiles)
    nextHeader = dicominfo(fullfile(CT, CTFiles(j).name));
    if header.ImagePositionPatient(3) > nextHeader.ImagePositionPatient(3);
        header = nextHeader;
    end
end
%translate CT header properties
ctProperties.PixelSpacing = header.PixelSpacing';
ctProperties.SliceThickness =  header.SliceThickness;
ctProperties.Rows =  header.Rows;
ctProperties.Columns =  header.Columns;
ctProperties.ImageOrientationPatient =  header.ImageOrientationPatient';
ctProperties.ImagePositionPatient =  header.ImagePositionPatient';
ctProperties.CTFileLength =  length(CTFiles);
return;
tic;
disp('GTV1 Time');
calculateStructureDataWrapper( ...
    ctProperties,     ... The path where the CT is located, search for CT.*
    RTDOSE,   ... The path where the planning dose is stored, if desired output is volume, insert null
    RTSTRUCT, ... The path where the RTPLAN is stored
    {'GTV-1'}, ...
    '', ...
    '', ... %if desired output is volume, insert 'null'
    '', ...
    'volume')
toc;
disp('GTV2 Time)');
tic;
calculateStructureDataWrapper( ...
    ctProperties,     ... The path where the CT is located, search for CT.*
    RTDOSE,   ... The path where the planning dose is stored, if desired output is volume, insert null
    RTSTRUCT, ... The path where the RTPLAN is stored
    {'GTV-1', 'GTV-2'}, ...
    '+', ...
    '', ... %if desired output is volume, insert 'null'
    '', ...
    'volume')
toc;
disp('mean eso dose:');
tic;
calculateStructureDataWrapper( ...
    ctProperties,     ... The path where the CT is located, search for CT.*
    RTDOSE,   ... The path where the planning dose is stored, if desired output is volume, insert null
    RTSTRUCT, ... The path where the RTPLAN is stored
    {'Esophagus'}, ...
    '', ...
    'mean', ... %if desired output is volume, insert 'null'
    '', ...
    'dose')
toc;
disp('max eso dose:');
tic;
calculateStructureDataWrapper( ...
    ctProperties,     ... The path where the CT is located, search for CT.*
    RTDOSE,   ... The path where the planning dose is stored, if desired output is volume, insert null
    RTSTRUCT, ... The path where the RTPLAN is stored
    {'Esophagus'}, ...
    '', ...
    'max', ... %if desired output is volume, insert 'null'
    '', ...
    'dose')
toc;
disp('mean lung dose:');
tic;
calculateStructureDataWrapper( ...
    ctProperties,     ... The path where the CT is located, search for CT.*
    RTDOSE,   ... The path where the planning dose is stored, if desired output is volume, insert null
    RTSTRUCT, ... The path where the RTPLAN is stored
    {'Lung_L','Lung_R','GTV'}, ...
    {'+', '-'}, ...
    'mean', ... %if desired output is volume, insert 'null'
    '', ...
    'dose')
toc;