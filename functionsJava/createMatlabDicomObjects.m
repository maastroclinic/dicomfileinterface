%CREATEMATLABDICOMOBJECTS provides Java with the necessary object to perform
%calculations with CALCULATESTRUCTEDATAWRAPPER. To shorten computation
%times this load was split from the calculations
%
%   DATA = CREATEMATLABDICOMOBJECTS(pathStruct, pathDose, ctProperties, volumeNames)
%   -----------------------------------------------------------------------
%   |varname    | type      | info
%   -----------------------------------------------------------------------
%   |pathStruct | STRING    |path where the RTSTRUCT is stored
%   -----------------------------------------------------------------------
%   |pathDose   | STRING    |path where the RTDOSE is stored
%   -----------------------------------------------------------------------
%   |ct         | STRUCT    |either the CT properties created by java
%   |           | Ct        |Ct object of this matlab library
%   |           | STRING    |String containing the folder location of CtFiles
%   -----------------------------------------------------------------------
%   |volumeNames| CELL      |the ROI names/indexes that will be used for
%   |           |           |creating the RtVolume objects.
%   |           |           |create cell array to contain the wanted ROIs.
%   |           |           |EXAMPLE: {'GTV-1', 5, 'Lung_L', 10}
%   -----------------------------------------------------------------------

%   See also ROIDOSE, ROIVOLUME, RTDOSE, RTSTRUCT, CT, CALCULATIONGRID.
%

%   Software Development Team MAASTRO CLinic.

function outputStruct = createMatlabDicomObjects(pathStruct, pathDose, ct, volumeNames)

    outputStruct.hasFittedDose = [];

    if ~exist(pathStruct, 'file')
        EM = MException('matlabData:MissingParamater', 'A RT-STRUCT file was not correctly specified');
        throw(EM);
    end

    if ~exist(pathDose, 'file')
        %if no dose is provided it is already determined that the
        %fittedDose cannot be computed
        outputStruct.hasFittedDose = false;
    end

    if isempty(volumeNames)
        EM = MException('matlabData:MissingParamater', 'No Volume names provided');
        throw(EM);
    end

    try
        outputStruct.hasCtImageData = false;
        switch lower(class(ct))
            case 'struct'
                calcGrid = CalculationGrid(ct, 'java');
            case 'ct'
                calcGrid = CalculationGrid(ct, 'ct');
            case 'char'
                ct = Ct(ct, 'folder', false);
                calcGrid = CalculationGrid(ct, 'ct');
            case 'cell'
                outputStruct.ct = Ct(ct, 'files', true);
                calcGrid = CalculationGrid(ct, 'ct');
                outputStruct.hasCtImageData = true;
            otherwise
                EM = MException('matlabData:MissingParamater', 'No valid CT options provided');
                throw(EM);
        end
    catch EM
        throw(EM)
    end

    outputStruct.calcGrid = calcGrid;

    try
        rtStruct = RtStruct(pathStruct, calcGrid);
    catch EM
        throw(EM)
    end
    outputStruct.rtStruct = rtStruct;

    j = 0;
    for i = 1:length(volumeNames)
        try
            outputStruct.rtStruct.getRoiMask(volumeNames{i});
            j = j + 1;
            outputStruct.parsedVolumes(j) = java.lang.String(volumeNames{i});
        catch
            warning('dataWrapper:rtStruct', ['Could not generate bitmask for ROI ' volumeNames{i}])
        end
    end
    outputStruct.nrDelineations = j;

    outputStruct.rtDose = [];
    if isempty(outputStruct.hasFittedDose)
        try
            rtDose   = RtDose(pathDose, calcGrid);
            outputStruct.hasFittedDose = true;
        catch EM
            throw(EM)
        end

        outputStruct.rtDose = rtDose;
    end
end