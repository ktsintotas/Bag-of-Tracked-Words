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

dataPath = ('images path\'); 
dataFormat = '*.png'; % e.g., for png input data

% parameters' definitions
params = parametersDefinition();

% extraction of visual sensory information
[visualData, timer] = incomingVisualData(params, dataPath, dataFormat);

% dataset's frame rate definition
visualData.frameRate = %; 

% timers memory allocation
timer = timersInitialization(visualData, timer);

% 1) the vocabulary build
[BoTW, timer] = buildingDatabase(visualData, params, timer);
% 2)  the query procedure
[matches, BoTW, timer] = queryingDatabaseBaseline(params, visualData, BoTW, timer);

% load the ground truth data for the corresponding dataset
groundTruthMatrix = %;

% evaluate the results
results = methodEvaluation(params, matches, groundTruthMatrix);
