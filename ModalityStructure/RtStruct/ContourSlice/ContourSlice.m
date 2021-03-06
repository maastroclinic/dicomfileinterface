classdef ContourSlice
%CONTOURSLICE contains the information of a single ContourSlice
%
% CONSTRUCTOR
%  this = ContourSlice(contourSequenceItem) translates the information of a single item in the
%  (3006,0039) ROIContourSequence dicom tag
%
% See also: CONTOUR, CTSLICE
    properties
        x %in cm
        y %in cm
        z %in cm
        
        referencedSopInstanceUid
        referencedSopClassUid
        
        closedPlanar = true
    end
    
    methods
        function this = ContourSlice(contourSequenceItem)
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            
            this.x   =   contourSequenceItem.ContourData(1:3:end)/10;
            this.y   =   contourSequenceItem.ContourData(3:3:end)/10;
            this.z   =   -contourSequenceItem.ContourData(2:3:end)/10;
            
            this.referencedSopInstanceUid = contourSequenceItem.ContourImageSequence.Item_1.ReferencedSOPClassUID;
            this.referencedSopClassUid = contourSequenceItem.ContourImageSequence.Item_1.ReferencedSOPClassUID;
            
            if ~strcmp('CLOSED_PLANAR', contourSequenceItem.ContourGeometricType)
                this.closedPlanar = false;
            end
        end
        
        % -------- START GETTERS/SETTERS ----------------------------------
        function this = set.referencedSopInstanceUid(this, uid)
            if ~ischar(uid)
                throw(MException('MATLAB:ContourSlice', 'invalid uid for referencedSopInstanceUid'))
            else
                this.referencedSopInstanceUid = uid;
            end
        end
        
        function this = set.referencedSopClassUid(this, uid)
            if ~ischar(uid)
                throw(MException('MATLAB:ContourSlice', 'invalid uid for referencedSopClassUid'))
            else
                this.referencedSopClassUid = uid;
            end
        end
    end
end