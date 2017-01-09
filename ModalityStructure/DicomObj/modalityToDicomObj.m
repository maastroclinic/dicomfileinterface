function dicomObj = modalityToDicomObj(modalityObj)
%CONVERTTODICOMOBJ converts a modality object to a genaric dicomObj
%
% See also: DICOMOBJ, RTDOSE, RTIMAGE, RTPLAN, RTSTRUCT, CREATEMODALITYOBJ
    if isa(modalityObj, 'DicomObj')
        dicomObj = DicomObj();
        dicomObj.dicomHeader = modalityObj.dicomHeader;
    else
        throw(MException('MATLAB:CONVERTTODICOMOBJ:INVALIDINPUT', 'the provided object has to be a subclass of DicomObj'))
    end
end

