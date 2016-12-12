function contour = createContour( rtStruct, varargin )    
    if isnumeric(varargin{1})
        dicomHeader = dicomHeaderForRoiNumber(rtStruct, varargin{1});
    elseif ischar(varargin{1})
        dicomHeader = dicomHeaderForRoiName(rtStruct, varargin{1});
    else
        throw(MException('MATLAB:createContour', 'invalid roi selected, provice a number or a name'))
    end
    
    contour = Contour(dicomHeader);
end