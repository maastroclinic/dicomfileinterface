%DICOMFILEINTERFACE is an empty script which aims to help with using the library
%
% ************ HierarchyStructure ************
% DicomDatabase
%   |Patient
%       |Study
%           |Series
%               |DicomObj 
% 
% The DicomDatabase is meant to manage your dicom cohorts and provide some help with sorting the
% files. It creates a collection of ValueClass objects to model the data set.
% Use DicomDb for:
%  1) Modelling the DICOM reference tree
%  2) Collecting the TPS package for a specific plan for a patient
%  3) Create modality objects for unorted DICOM files
%
% *** WARNING *** all objects are kept in memory, when reading large data sets (>100 studies)
%   Matlab could run into memory issues!
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