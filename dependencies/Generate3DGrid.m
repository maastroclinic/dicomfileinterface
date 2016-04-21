% function Generate3DGrid
function Grid = Generate3DGrid(Dose3D,Ct,PixelSpacing,IsodoseCutOffValue)

% define 3D grid based on 3D RtDose and/or Ct grid
try
    % calculate grid vectors
    if ~isempty(Dose3D)
        if IsodoseCutOffValue > 0
            Dose3D = read_dicomrtdose(Dose3D.FileName);
            Y_DoseStart = [];
            Y_DoseEnd   = [];
            MaxValueDose = max(Dose3D.Image(:));
            for i = 1 : Dose3D.PixelNumYi
                if ~isempty(find(Dose3D.Image(:,i,1,:)>MaxValueDose*IsodoseCutOffValue/100, 1)) && isempty(Y_DoseStart)
                    Y_DoseStart      = Dose3D.PixelFirstYi+Dose3D.YiSliceValues(i);
                    Y_DoseStartIndex = i;
                end
                if ~isempty(find(Dose3D.Image(:,Dose3D.PixelNumYi-i+1,1,:)>MaxValueDose*IsodoseCutOffValue/100, 1)) && isempty(Y_DoseEnd)
                    Y_DoseEnd      = Dose3D.PixelFirstYi+Dose3D.YiSliceValues(Dose3D.PixelNumYi-i+1);
                    Y_DoseEndIndex = Dose3D.PixelNumYi-i+1;
                end
            end
        else
            Y_DoseStart      = Dose3D.PixelFirstYi;
            Y_DoseStartIndex = 1;
            Y_DoseEnd        = Dose3D.PixelFirstYi+Dose3D.YiSliceValues(end);
            Y_DoseEndIndex   = Dose3D.PixelNumYi;
        end
        X_Dose3D = (Dose3D.PixelFirstXi:Dose3D.PixelSpacingXi:Dose3D.PixelFirstXi+(Dose3D.PixelNumXi-1)*Dose3D.PixelSpacingXi)';
        Y_Dose3D = (Dose3D.PixelFirstYi+Dose3D.YiSliceValues)';
        Y_Dose3D = (Y_Dose3D(Y_DoseStartIndex:Y_DoseEndIndex));
        Z_Dose3D = (Dose3D.PixelFirstZi:Dose3D.PixelSpacingZi:Dose3D.PixelFirstZi+(Dose3D.PixelNumZi-1)*Dose3D.PixelSpacingZi)';
    end
    
    if ~isempty(Ct)
        X_CT = (Ct.PixelFirstXi:Ct.PixelSpacingXi:Ct.PixelFirstXi+(Ct.PixelNumXi-1)*Ct.PixelSpacingXi)';
        Y_CT = (Ct.PixelFirstYi:Ct.PixelSpacingYi:Ct.PixelFirstYi+(Ct.PixelNumYi-1)*Ct.PixelSpacingYi)';
        Z_CT = (Ct.PixelFirstZi:Ct.PixelSpacingZi:Ct.PixelFirstZi+(Ct.PixelNumZi-1)*Ct.PixelSpacingZi)';
    end
    
    % calculate 3D grid
    % Both Dose and Ct are available
    if ~isempty(Dose3D) && ~isempty(Ct)
        [~,Grid.CropIndices(1)] = min(abs(X_CT-Dose3D.PixelFirstXi+1.0));
        [~,Grid.CropIndices(2)] = min(abs(X_CT-Dose3D.PixelFirstXi-(Dose3D.PixelNumXi-1)*Dose3D.PixelSpacingXi-1.0));
        [~,Grid.CropIndices(3)] = min(abs(Y_CT-Y_DoseStart+1.0));
        [~,Grid.CropIndices(4)] = min(abs(Y_CT-Y_DoseEnd-1.0));
        [~,Grid.CropIndices(5)] = min(abs(Z_CT-Dose3D.PixelFirstZi+1.0));
        [~,Grid.CropIndices(6)] = min(abs(Z_CT-Dose3D.PixelFirstZi-(Dose3D.PixelNumZi-1)*Dose3D.PixelSpacingZi-1.0));
    end
    
    % Only Dose is available
    if ~isempty(Dose3D) && isempty(Ct)
        Grid.CropIndices    = [1 Dose3D.PixelNumXi 1 length(Y_Dose3D) 1 Dose3D.PixelNumZi];
    end
    
    % Only Ct is available
    if isempty(Dose3D) && ~ isempty(Ct)
        Grid.CropIndices    = [1 Ct.PixelNumXi 1 Ct.PixelNumYi 1 Ct.PixelNumZi];
    end
    
    %Set pixel first and spacing properties
    if ~isempty(Ct)
        Grid.PixelFirstXi   = X_CT(Grid.CropIndices(1));
        Grid.PixelFirstYi   = Y_CT(Grid.CropIndices(3));
        Grid.PixelFirstZi   = Z_CT(Grid.CropIndices(5));
       
        Grid.PixelSpacingXi = Ct.PixelSpacingXi;
        Grid.PixelSpacingYi = Ct.PixelSpacingYi;
        Grid.PixelSpacingZi = Ct.PixelSpacingZi;
        
        if isempty(PixelSpacing)
            PixelSpacing  = [Ct.PixelSpacingXi Ct.PixelSpacingYi Ct.PixelSpacingZi];
        end
    elseif ~isempty(Dose3D)
        Grid.PixelFirstXi   = X_Dose3D(Grid.CropIndices(1));
        Grid.PixelFirstYi   = Y_Dose3D(Grid.CropIndices(3));
        Grid.PixelFirstZi   = Z_Dose3D(Grid.CropIndices(5));
        
        Grid.PixelSpacingXi = Dose3D.PixelSpacingXi;
        Grid.PixelSpacingYi = Y_Dose3D(2)-Y_Dose3D(1);
        Grid.PixelSpacingZi = Dose3D.PixelSpacingZi;
        
        if isempty(PixelSpacing)
            PixelSpacing  = [Dose3D.PixelSpacingXi Y_Dose3D(2)-Y_Dose3D(1) Dose3D.PixelSpacingZi];
        end
    end
    
    % Neither Dose or Ct are available
    if isempty(Dose3D) && isempty(Ct)
        Grid = [];
    end
    
    Grid.PixelNumXi     = Grid.CropIndices(2)-Grid.CropIndices(1)+1;
    Grid.PixelNumYi     = Grid.CropIndices(4)-Grid.CropIndices(3)+1;
    Grid.PixelNumZi     = Grid.CropIndices(6)-Grid.CropIndices(5)+1;
    Grid.PixelNumXi     = round((Grid.PixelNumXi-1)*(Grid.PixelSpacingXi/PixelSpacing(1)))+1;
    Grid.PixelNumYi     = round((Grid.PixelNumYi-1)*(Grid.PixelSpacingYi/PixelSpacing(2)))+1;
    Grid.PixelNumZi     = round((Grid.PixelNumZi-1)*(Grid.PixelSpacingZi/PixelSpacing(3)))+1;
    Grid.PixelSpacingXi = PixelSpacing(1);
    Grid.PixelSpacingYi = PixelSpacing(2);
    Grid.PixelSpacingZi = PixelSpacing(3);
    Grid.X              = (Grid.PixelFirstXi:Grid.PixelSpacingXi:Grid.PixelFirstXi+(Grid.PixelNumXi-1)*Grid.PixelSpacingXi)';
    Grid.Y              = (Grid.PixelFirstYi:Grid.PixelSpacingYi:Grid.PixelFirstYi+(Grid.PixelNumYi-1)*Grid.PixelSpacingYi)';
    Grid.Z              = (Grid.PixelFirstZi:Grid.PixelSpacingZi:Grid.PixelFirstZi+(Grid.PixelNumZi-1)*Grid.PixelSpacingZi)';
    
    clear Dose3D;
    clear Ct;
catch
    Grid = [];
end
end