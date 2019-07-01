% 

% Copyright 2019, Konstantinos Tsintotas
% ktsintot@pme.duth.gr
%
% This file is part of Bag-of-Tracked-Words framework for loop closure
% detection
%
% Bag-of-Tracked-Words framework is free software: you can redistribute 
% it and/or modify it under the terms of the MIT License as 
% published by the corresponding authors.
%  
% Bag-of-Tracked-Words pipeline is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% MIT License for more details. <https://opensource.org/licenses/MIT>

function params = parametersDefinition()
    
    % visual information
    params.visualData.load = true;
    params.visualData.save = true;
    
    % database
    params.buildingDatabase.load = true;
    params.buildingDatabase.save = true;
    
    % matches
    params.queryingDatabase.load = true;
    params.queryingDatabase.save = true;
    
    % evaluation
    params.visualizationResults = true;
    
    % number of maximum points fed into the tracker, ni
    params.numPointsToTrack = int16(200);
    % minimum track word length, rho
    params.trackLength = int8(4);
    % minimum pointss distance, alpha
    params.pointsDist = single(5);
    % minimum descriptors distance, vita
    params.descriptorsDist = single(0.6);
    % RANSAC inliers, phi
    params.inliersTheshold = int16(9);
    % loop closure threshold, delta
    params.probabilityThreshold = 2e-11;
    % verification step 
    params.verification = true;

end