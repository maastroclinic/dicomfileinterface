classdef CtScan < DicomObj
    %CTSCAN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ctSlices = CtSlice();
        sortedCtSlices;
    end
    
    methods
        function this = CtScan(varargin)
            if nargin == 0 %preserve standard empty constructor
                return;
            end
            
            %if the input is a folder, create file list array
            if ischar(varargin{1})
                fileNames = scanFolder(varargin{1}, varargin{3});
                this = this.addListOfFiles(fileNames, varargin{2});
            elseif isa(varargin{1}, 'DicomObj')
                this = this.addListOfObjects(varargin{1});
            elseif isa(varargin{1}, 'cell')
                list = varargin{1};
                if ischar(list{1}) && exist(list{1}, 'file')
                    this = this.addListOfFiles(list, varargin{3});
                else
                    throw(MException('MATLAB:CtScan:constructor', 'invalid input, the first file in the file list does not exist'));
                end
            else
                throw(MException('MATLAB:CtScan:constructor', 'invalid input type, please give a folder location or a file list as a cell array'));
            end
        end
        
        function this = addListOfObjects(this, dicomObj)
            this = constructorParser(this, 'ct', dicomObj);
            for i = 1:length(dicomObj)
                this.ctSlices(dicomObj(i)); 
            end
        end
        
        function this = addListOfFiles(this, files, UseVrHeuristic)
            this = constructorParser(this, 'ct', files{1}, UseVrHeuristic);
            for i = 1:length(files)
                ctSlice = CtSlice(files{i}, UseVrHeuristic);
                this.ctSlices = ctSlice; 
            end
        end
        
        function this = set.ctSlices(this, ctSlice)
            if isempty(this.ctSlices(1).dicomHeader)
                this.ctSlices(1) = ctSlice;
            else
                index = length(this.ctSlices) + 1;
                this.ctSlices(index) = ctSlice;
            end
        end
        
        function out = get.ctSlices(this)
            if ~isempty(this.ctSlices(1).dicomHeader)
                out = this.ctSlices;
            else
                out = CtSlice();
            end
        end
        
        function out = get.sortedCtSlices(this)
            out = orderStructureArray(this.ctSlices, 'instanceNumber');
        end
        
        function this = deleteCtSlices(this)
            this.ctSlices = [];
        end
        
        function this = deleteSortedCtSlices(this)
            this.sortedCtSlices =[];
        end
    end
end