%DICOMFILEINTERFACE is an empty script which aims to help with using the library
%
% ************ HierarchyStructure ************
% DicomDatabase
%   |Patient
%       |Study
%           |Series
%               |DicomObj 
% *** more info will be added here later! ***
%
% ************ ModalityStructure ************* 
% CtScan
%   |CtSlice    -> Image|
%                |      |
%                |      |
% RtDose         |  -> Image ->         |
%                |                      DoseVolumeHistogram
%                ----------------|      |
% RtStruct      -> Contour  - > VolumeOfInterest
%
% 1) The CtScan is used to define a grid as an Image
% 2) The RtDose representation is matched to the CtScan grd
% 3) A contour in RtStract is represented as a volume of interest matchted to the CtScan grid
% 4) Combining the dose image and volume of interest will create a DVH
% *** please use the help of the corresponding objects for a more detailed description ***
%
% Each part of the library as a 
%
% See also: DICOMDATABASE, PATIENT, STUDY, SERIES, DICOMOBJ, CTSCAN, RTDOSE RTIMAGE, RTPLAN
% RTSTRUCT, IMAGE, VOLUMEOFINTEREST, DOSEVOLUMEHISTOGRAM