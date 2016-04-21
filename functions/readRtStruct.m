function newStruct = readRtStruct(fileLocation, useVrHeuristics)
%READRTSTRUCT create te RtStruct object from a file location

        
    newStruct = Rtstruct();
    dicomHeader = dicominfo(fileLocation, 'UseVRHeuristic', useVrHeuristics);
end