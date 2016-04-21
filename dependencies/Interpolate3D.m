% function Interpolate3D
function Vq = Interpolate3D(X,Y,Z,V,Xq,Yq,Zq,METHOD,RIGID_TRANSFORMATION)

% perform 3D interpolation
try
    [Xo, Yo, Zo] = meshgrid(X,Y,Z);
    [Xn, Yn, Zn] = meshgrid(Xq,Yq,Zq);
    if ~isempty(RIGID_TRANSFORMATION) && size(RIGID_TRANSFORMATION,1) ==4 && size(RIGID_TRANSFORMATION,2)==4
        T_Xn = Xn - RIGID_TRANSFORMATION(2,4);
        T_Yn = Yn - RIGID_TRANSFORMATION(1,4);
        T_Zn = Zn - RIGID_TRANSFORMATION(3,4);
        
        R       = RIGID_TRANSFORMATION(1:3,1:3);
        RD      = R * [T_Xn(:)' ; T_Yn(:)' ; T_Zn(:)'];
        CubeSize  = size(T_Xn);
        
        clear Xn Yn Zn;
        
        Xn = reshape(RD(1,:), CubeSize);
        Yn = reshape(RD(2,:), CubeSize);
        Zn = reshape(RD(3,:), CubeSize);
    end
    
    Vq = interp3(double(Xo),double(Yo),double(Zo),double(V),double(Xn),double(Yn),double(Zn), METHOD, double(0));
    
% If the interpolation failed on the resampled data, 
% let matlab's build-in interpolation method create a meshgrid. 
% This is computationally more expensive though.
catch EM
    warning('Interpolate3D:Interpolate', getReport(EM));
    Vq = interp3(double(X),double(Y),double(Z),double(V),double(Xq),double(Yq),double(Zq),METHOD,double(0));
end