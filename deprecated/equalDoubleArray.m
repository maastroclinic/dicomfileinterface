%compare array a to b with precision p.
% select a precision by setting a 10^-n fraction for p.
% example p = 0.0001 

function out = equalDoubleArray(a,b,p)
    out = []; %#ok<NASGU>
    if ~isnumeric(p) && size(p,1) == 1 && size(p,2) == 1 
        throw(MException('equalDoubleArray:InvalidPrecision', 'p must be a singe double value'));
    end
    if p > 1
        throw(MException('equalDoubleArray:InvalidPrecision', 'p must be a double between 1 and 0'));
    end
    if ~isnumeric(a)
        throw(MException('equalDoubleArray:InvalidCompareStruct', 'a must be a double array'));
    end
    if ~isnumeric(b)
        throw(MException('equalDoubleArray:InvalidCompareStruct', 'b must be a double array'));
    end
    
    out = true;  
    
    if ~size(a) == size(b)
        out = false;
        return;
    end

    for i = 1:size(a,1)
        for j = 1:size(a,2)
            if round(a(i,j)/p) ~= round(b(i,j)/p)
                out = false;
                return;
            end
        end
    end      
end
