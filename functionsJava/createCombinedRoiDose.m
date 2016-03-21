function [ structure ] = createCombinedRoiDose( wrapperData, ...
                                                        volumeNames, ...
                                                        combinationOperators)
rtDose = wrapperData.rtDose;
rtStruct = wrapperData.rtStruct;
calcGrid = wrapperData.calcGrid;

% No volume name specified
if isempty(volumeNames)
    throw(MException('matlabCalcualtions:MissingParamater', 'A volume was not specified'));
end

% The number of operators should be one lower than the number of
% structures
if ~isempty(combinationOperators) && (length(volumeNames) - 1) ~= length(combinationOperators)
    throw(MException('matlabCalculations:InvalidOperatorCount', 'The number of combinationOperators specified does not match the number of volumes'));
end

% Calculate the (combined) volume
% Be tolerant to use of string or cell
if iscell(volumeNames)
    name = volumeNames{1};
else
    name = volumeNames;
end

%  build RoiDose object
% Create object with the first structure
% Check if desired output is volume, or dvh/dose:
if isempty(rtDose)
    structure = RoiDose(name, calcGrid, rtStruct);
else
    structure = RoiDose(name, calcGrid, rtStruct, rtDose);
end

% If there are operator preform a rolling sum
for i=1:length(combinationOperators)

    % Create object with the next structure
    % Check if desired output is volume, or dvh/dose:
    if isempty(rtDose)
        nextStructure = RoiDose(volumeNames{i + 1}, calcGrid, rtStruct);
    else
        nextStructure = RoiDose(volumeNames{i + 1}, calcGrid, rtStruct, rtDose);
    end


    % Be tolerant to use of string or cell
    if iscell(combinationOperators)
        operator = combinationOperators{i};
    else
        operator = combinationOperators;
    end

    % Select the proper mathematical operation
    switch operator
        case '+'
            structure = structure + nextStructure;
        case '-'
            structure = structure - nextStructure;
        otherwise
            throw(MException('matlabCalculations:InvalidOperator', ['An operator (' operator ') was specified that is not supported.']));
    end

end