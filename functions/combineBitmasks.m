function [ combinedMask ] = combineBitmasks(bitmasks, operators)
    %% input parsing
    if ~iscell(bitmasks);
        throw(MException('combineBitmasks:InputContainerMismatch','bitmasks should be cell array of logicals'));
    end
    
    for i = 1:length(bitmasks)
        if ~islogical(bitmasks{i});
            throw(MException('combineBitmasks:InputTypeMismatch','bitmasks should be cell array of logicals'));
        end
    end
    
    if ~iscell(operators)
        throw(MException('combineBitmasks:InputContainerMismatch','operators should be cell array of strings'));
    end
    
    for i = 1:length(operators)
        if ~ischar(operators{i});
            throw(MException('combineBitmasks:InputTypeMismatch','bitmasks should be cell array of strings'));
        end
    end
    
    if length(bitmasks)~=(length(operators)+1)
        throw(MException('combineBitmasks:InputDimensionMismatch','There should be n-1 operators for n bitmasks'));
    end
    
    %% processing
    combinedMask = bitmasks{1};
    for i = 1:length(operators)
        switch lower(operators{i})
            case {'-', 'minus'}
                combinedMask = combinedMask &~ bitmasks{i+1};
            case {'+', 'plus'}
                combinedMask = combinedMask | bitmasks{i+1};
            otherwise
                throw(MException('combineBitmasks:InvalidInput','invalid operation'));
        end
    end
end