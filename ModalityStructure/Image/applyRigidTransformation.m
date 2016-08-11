function [ Xn, Yx, Zn ] = applyRigidTransformation( Xq, Yq, Zq, rigidTransformation)
%APPLYRIGIDTRANSFORMATION contains the DGRT code that is used to apply rigid transformation to the
% image vectors. Do not understand this yes.

    if isempty(rigidTransformation) || size(rigidTransformation,1) ~= 4 && size(rigidTransformation,2)~=4
        throw(MException('MATLAB:ApplyRigidTransformation', 'invalid transformation matrix'))
    end
    [Xn, Yn, Zn] = meshgrid(Xq,Yq,Zq);
    if ~isempty(rigidTransformation) && size(rigidTransformation,1) ==4 && size(rigidTransformation,2)==4
        T_Xn = Xn - rigidTransformation(2,4);
        T_Yn = Yn - rigidTransformation(1,4);
        T_Zn = Zn - rigidTransformation(3,4);
        
        R       = rigidTransformation(1:3,1:3);
        RD      = R * [T_Xn(:)' ; T_Yn(:)' ; T_Zn(:)'];
        CubeSize  = size(T_Xn);
        
        clear Xn Yn Zn;
        
        Xn = reshape(RD(1,:), CubeSize);
        Yn = reshape(RD(2,:), CubeSize);
        Zn = reshape(RD(3,:), CubeSize);
    end
end

