% function VolumeResample
%
% varargin{1} = Rigid registration cube. 
% Only works when a full interpolation is used.
% The rigid registration cube has to be a 4 * 4 
function Volume3D = VolumeResample(Volume3D,X,Y,Z,Xq,Yq,Zq,varargin)

% Resample the 3D volume

RigidRegistration = [];
if size(varargin,2) == 1
    RigidRegistration = double(varargin{1});
    % If the rigid registration is not 4 * 4
    if not(size(RigidRegistration,1) == 4 && size(RigidRegistration,2) == 4)
        RigidRegistration = [];
    end
end
Volume3D = Interpolate3D(Y,X,Z,squeeze(Volume3D),Yq,Xq,Zq','linear',RigidRegistration);
end
