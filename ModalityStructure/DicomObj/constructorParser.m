function [ dicomObj ] = constructorParser( dicomObj, modality, varargin )
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

