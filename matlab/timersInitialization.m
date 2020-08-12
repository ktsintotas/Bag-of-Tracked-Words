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

function timer = timersInitialization(visualData, timer)

    %  memory allocation for feature tracking timer
    timer.trackingPoints = zeros(visualData.imagesLoaded, 1,'single');
    % memory allocation for guided feature selection timer
    timer.guidedFeatureSelection = zeros(visualData.imagesLoaded, 1,'single');
    % memory allocation for brute force database search timer
    timer.databaseSearch = zeros(visualData.imagesLoaded, 1,'single');
    % memory allocation for votes distribution timer
    timer.votesDistribution = zeros(visualData.imagesLoaded, 1,'single');
    % memory allocation for binomial scoring timer
    timer.binomialScoring = zeros(visualData.imagesLoaded, 1,'single');
    % memory allocation for geometrical verification timer
    timer.geometricalVerification = zeros(visualData.imagesLoaded, 1,'single');    
    
end
