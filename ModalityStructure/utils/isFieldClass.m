function isField = isFieldClass( obj, fieldName )
    isField = false;
    names = fieldnames(obj);
    for i = 1:length(names)
        if strcmp(fieldName, names{i})
            isField = true;
            return;
        end
    end
end