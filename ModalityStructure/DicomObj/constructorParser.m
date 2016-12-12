function dicomObj = constructorParser(dicomObj, modality, varargin )
%CONSTRUCTOR PARSER is a helper function that is used by all the DicomObj based classes.
% this function is not required for anything else.
% dicomObj = constructorParser(dicomObj, modality, varargin) 
%  varargin{1} can be a DicomObj or a file path.
%  varargin{2} must be a boolean for the useVrHeuristic setting when providing a file path
%
%See also: DICOMOBJ, RTDOSE, RTIMAGE, RTPLAN, RTSTRUCT
    if ischar(varargin{1})  
        dcm = DicomObj(varargin{1}, varargin{2});
        dicomObj.dicomHeader = dcm.dicomHeader;
    elseif isa(varargin{1}, 'DicomObj')
        dicomObj.dicomHeader = varargin{1}.dicomHeader;
    else
        throw(MException('MATLAB:constructorParser', 'Invalid class for constructor input'));
    end

    if ~strcmpi(dicomObj.modality, modality)
        throw(MException('MATLAB:constructorParser', ['Cannot create ' modality ' for modality '  dicomObj.modality]));
    end
end

