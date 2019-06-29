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

clear all; close all;
dataPath = ('C:\Users\Konstantinos\OneDrive - Democritus University of Thrace\PhD Documents\13-Datasets\KITTI\data_odometry_gray\sequences\00\image_1\'); 
dataFormat = '*.png'; % e.g., for png input data

params = parametersDefinition();

visualData = incomingVisualData(params, dataPath, dataFormat);
clear vars dataPath dataFormat

tic
BoTW = buildingDatabase(visualData, params);
toc

tic
matches = queryingDatabase(params, visualData, BoTW);
toc



