function [ newArray ] = orderStructureArray(array, sortFieldName)
    if ischar(sortFieldName) && isFieldClass(array, sortFieldName)
        
        index = zeros(length(array), 1);
        for i = 1:length(array)
            if ~isnumeric(array(i).(sortFieldName))
                throw(MException('MATLAB:orderStructureArray', 'the sortfieldname does not contain an index'));
            end
            
            index(i,1) = array(i).(sortFieldName);
        end
        
        [~ , newIndex] = sort(index);
        newArray = array(newIndex);
    else
        throw(MException('MATLAB:orderStructureArray', 'please provide a valid structure and fieldname'));
    end
end

