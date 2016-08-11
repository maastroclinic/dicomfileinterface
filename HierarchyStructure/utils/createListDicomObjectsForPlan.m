function data = createListDicomObjectsForPlan(patientObj, planLabel, ctDir)
    if nargin == 2
        ctDir = false; 
    end

    data = createHeader();
    
    patientId = patientObj.id;
    [plan, dose, struct, ct] = createPlanPackage(patientObj, planLabel);
    
    data = addEntry(data, patientId, planLabel,...
                    'RTPLAN', ...
                    plan.studyInstanceUid, ...
                    plan.seriesInstanceUid, ...
                    plan.sopInstanceUid, ...
                    plan.filename);
                
    for i = 1:length(dose)
       data = addEntry(data, patientId, planLabel,...
                    'RTDOSE', ...
                    dose(i).studyInstanceUid, ...
                    dose(i).seriesInstanceUid, ...
                    dose(i).sopInstanceUid, ...
                    dose(i).filename); 
    end
    
    data = addEntry(data, patientId, planLabel,...
                    'RTSTRUCT', ...
                    struct.studyInstanceUid, ...
                    struct.seriesInstanceUid, ...
                    struct.sopInstanceUid, ...
                    struct.filename);
    if ctDir
        folder = ct.ctSlices(1).filename;
        backslashes = regexp(folder, '\\');
        if ~ isempty(backslashes)
            folder = folder(1:backslashes(end));
        end
        data = addEntry(data, patientId, planLabel,...
                        'CT', ...
                        ct.ctSlices(1).studyInstanceUid, ...
                        ct.ctSlices(1).seriesInstanceUid, ...
                        ct.ctSlices(1).sopInstanceUid, ...
                        folder);
    else
        for i = 1:ct.numberOfSlices       
            data = addEntry(data, patientId, planLabel,...
                        'CT', ...
                        ct.ctSlices(i).studyInstanceUid, ...
                        ct.ctSlices(i).seriesInstanceUid, ...
                        ct.ctSlices(i).sopInstanceUid, ...
                        ct.ctSlices(i).filename);
        end
    end
end

function data = createHeader()
    data{1,1} = 'patientId';
    data{1,2} = 'planLabel';
    data{1,3} = 'modality';
    data{1,4} = 'studyInstanceUid';
    data{1,5} = 'seriesInstanceUid';
    data{1,6} = 'sopInstanceUid';
    data{1,7} = 'fullfile location';
end

function data = addEntry(data, patientId, planLabel, modality, studyUid, seriesUid, sopUid, file)
    i = size(data,1) + 1;
    data{i,1} = patientId;
    data{i,2} = planLabel;
    data{i,3} = modality;
    data{i,4} = studyUid;
    data{i,5} = seriesUid;
    data{i,6} = sopUid;
    data{i,7} = file;
end

