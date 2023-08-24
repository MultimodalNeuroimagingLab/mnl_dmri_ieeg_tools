function [valueMatrix, xyPairs, numValues] = analyzeStruct(myStruct, xDim, yDim)
    
%   Jordan Bilderbeek August 3 2023
%
%   analyzeStruct parses through a given structure and identifies if 
%   substructures contain variables or are empty
%   
%   INPUTS:
%       a) myStruct - your structure
%       b) xDim - dimensions of myStruct(x)
%       c) yDim - dimensions of myStruct.substruct(y)
%
%   OUTPUTS:
%       a) valueMatrix - logical matrix with dimensions of X by Y which is true
%       for the given x and y where the substruct is nonempty
%       b) xyPairs - pairs of indexable x and y values (used for iterating
%       through structure in for loop efficiently)
%       c) numValues - the number of indexable x and y values (used for length
%       of iterating through struct)
%
    
%% analyzeStruct
    valueMatrix = false(xDim, yDim);

    % Iterate through x and y dimensions
    for x = 1:xDim
        for y = 1:yDim
            angle=[];
            % Check if the value is not empty and set the corresponding
            % position in the logical matrix
            for jj=1:length(myStruct(x).trackstats(y).angle)
                tmp=myStruct(x).trackstats(y).angle{jj};
                angle=[tmp; angle];
            end
            
            angle=rmmissing(angle);
            if ~isempty(angle)
                valueMatrix(x, y) = true;
            end
        end
    end
    
    % Find the x, y pairs and the number of values
    [xValues, yValues] = find(valueMatrix);
    xyPairs = [xValues, yValues];
    numValues = numel(xValues);
    
    disp('Value Matrix:')
    disp(valueMatrix)
end
