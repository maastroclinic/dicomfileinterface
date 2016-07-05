% %read rtstruct
% header = dicominfo('D:\TestData\12345\RTSTRUCT\FO-4073997332899944647.dcm');
% 
% %find left lung
% iStr = fieldnames(header.StructureSetROISequence);
% num = [];
% for i=1:length(iStr)
%     if strcmp('Lung_L', header.StructureSetROISequence.(iStr{i}).ROIName)
%         num = header.StructureSetROISequence.(iStr{i}).ROINumber;
%         break;
%     end
% end
% if isempty(num)
%     disp('ROI Lung_L not found')
%     return;
% end
% 
% %find data for left lung
% iStr = fieldnames(header.ROIContourSequence);
% data = [];
% for i=1:length(iStr)
%     if header.ROIContourSequence.(iStr{i}).ReferencedROINumber == num
%         data = header.ROIContourSequence.(iStr{i}).ContourSequence;
%         break;
%     end
% end
% if isempty(data)
%     disp('contour data sequence for Lung_L not found')
%     return;
% end
% 
% %get data for first slice
% x   =   data.Item_1.ContourData(1:3:end)/10;
% y   =   data.Item_1.ContourData(3:3:end)/10;
% z   =   -data.Item_1.ContourData(2:3:end)/10;

%read dicom data
data = double(dicomread('D:\TestData\12345\CT\FO-169300684774812893.dcm'));
header = dicominfo('D:\TestData\12345\CT\FO-169300684774812893.dcm');

%transform image
data = double((data * header.RescaleSlope) + header.RescaleIntercept);
% data = data.*3; %upscaled the contrast
figure;
imagesc(data);
scale = gray(2000);
color = scale(1:end, :);
colormap(color);



