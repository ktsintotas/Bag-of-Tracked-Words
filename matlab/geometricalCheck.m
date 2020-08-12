% 

% Copyright 2019, Konstantinos Tsintotas
% ktsintot@pme.duth.gr
%
% This file is part of iBoTW framework for visual loop closure detection
%
% iBoTW framework is free software: you can redistribute 
% it and/or modify it under the terms of the MIT License as 
% published by the corresponding authors.
%  
% iBoTW pipeline is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% MIT License for more details. <https://opensource.org/licenses/MIT>

function [properImage, inliersTotal] = geometricalCheck(It, iBoTW, params, candidate, visualData)
     
    properImage = uint16(0);
    inliersTotal = uint16(0);    
    
    indexPairs = matchFeatures(iBoTW.queryDescriptors{It}, visualData.features{candidate}, ...
        'Unique', true, 'Method', 'Exhaustive', 'MatchThreshold', 10.0, 'MaxRatio', params.queryingDatabase.maxRatio);

    if size(indexPairs, 1) >= 9
        matchedPoints1 = iBoTW.queryPoints{It}(indexPairs(:, 1), :);
        matchedPoints2 = visualData.points{candidate}.Location(indexPairs(:, 2), :);
        try
            [~, inliersIndex, ~] = estimateFundamentalMatrix(matchedPoints1, matchedPoints2, ...
                'Method', 'RANSAC', 'DistanceType', 'Algebraic', 'DistanceThreshold', 1);
            if sum(inliersIndex) >= params.queryingDatabase.inliersTheshold
                properImage = candidate;
                inliersTotal = sum(inliersIndex);        
            end
        catch            
        end
    end    
end
