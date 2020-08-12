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

function [matches, timer] = queryingDatabase(params, visualData, BoTW, timer)

    if params.queryingDatabase.load == true && exist('results/queryingDatabase.mat', 'file')    
        load('results/queryingDatabase.mat');
        
    else
        
        % memory allocation for system's outputs
        matches = matchesInitialization(visualData);
        
        for It = uint16(1 : visualData.imagesLoaded)
            
            disp(It);
            
            % B.1 MAP VOTING
            % indicating the vocabulary area which would be avoided  
            if BoTW.maximumActivePoint(It) < visualData.frameRate
                lastDatabaseLocation = It - ceil(4 * visualData.frameRate);
            else
                lastDatabaseLocation = It - ceil(4 * BoTW.maximumActivePoint(It));
            end
            if lastDatabaseLocation > 0
                databaseIndexTemp = find(BoTW.twIndex(:, 2) <= lastDatabaseLocation);                
                if ~isempty(databaseIndexTemp)                    
                    databaseIndexTemp = databaseIndexTemp(end);
                    % visual vocabulary to be searched
                    database = BoTW.bagOfTrackedWords(1 : databaseIndexTemp, :);                     
                else
                     database = single([]);
                end
            else
                database = single([]);
            end
            
            % vote aggregation
            if ~isempty(database) && size(BoTW.queryDescriptors{It}, 1) > params.queryingDatabase.inliersTheshold
                
                % start the timer for the database search
                tic
                queryIdxNN = single(knnsearch(database, BoTW.queryDescriptors{It}, 'K', 1, 'NSMethod', 'exhaustive'));
                % stop the timer for the database search
                timer.databaseSearch(It, 1) = toc;
                     
                % start the timer for the votes' distribution
                tic 
                % votes distribution through the Nearest Neighbor procedure
                for v = uint16(1 : length(queryIdxNN))                    
                    votedLocations = uint16(find(BoTW.twLocationIndex(queryIdxNN(v), 1 : lastDatabaseLocation) == true));
                    matches.votesMatrix(It, votedLocations) = matches.votesMatrix(It, votedLocations) + 1;                    
                end
                % stop the timer for the votes' distribution
                timer.votesDistribution(It, 1) = toc;   

                % NAVIGATION USING PROBABILISTIC SCORING                
                % images which gather votes
                imagesForBinomial = uint16(find(matches.votesMatrix(It, 1 : lastDatabaseLocation) >= 0.01 * size(BoTW.queryDescriptors{It}, 1)));
                % start the timer for the binomial scoring
                tic
                % locations which pass the two conditions
                candidateLocationsObservation = zeros(1, lastDatabaseLocation, 'double');
                % number of Tracked Words within the searching area 
                LAMDA = databaseIndexTemp;
                % number of query’s Tracked Points (number of points after the guided feature-detection)
                N = size(BoTW.queryDescriptors{It}, 1);                
                % number of accumulated votes of database location l
                xl = double(matches.votesMatrix(It, imagesForBinomial));
                % number of TWs members in l over the size of the BoTW list (without the rejected locations)
                p = double(BoTW.lamda(imagesForBinomial)) / LAMDA;
                % distribution’s expected value 
                expectedValue = N*p;
                % probability computation for the selected images in the database
                locationProbability = binopdf(xl, N , p);
                % binomial Matrix completion
                matches.binomialMatrix(It, imagesForBinomial) = locationProbability;
                % the binomial expected value on each location has to
                % satisfy two conditions, (1) loop closure threshold and (2) over expected value xl(t) > E [Xi(t)]
                Condition2Locations = uint16(find(xl > expectedValue));                
                % locations which satisfy condition 2 and condition 1 - observation 3
                if ~isempty(Condition2Locations) ... 
                        && ~isempty(find(locationProbability(Condition2Locations) < params.queryingDatabase.observationThreshold, 1))                    
                    candidateLocations = imagesForBinomial(Condition2Locations(locationProbability(Condition2Locations) < params.queryingDatabase.observationThreshold));
                    candidateLocationsObservation(candidateLocations) = matches.binomialMatrix(It, candidateLocations);
                end
                % stop the timer for the binomial scoring
                timer.binomialScoring(It, 1) = toc;
                
                % define the appropriate loop closing image for the image
                % which has the lowest probability score
                if sum(candidateLocationsObservation) ~= 0
                    [probability, ~] = min(candidateLocationsObservation(candidateLocationsObservation>0));
                    candidates = find(candidateLocationsObservation == probability, 1);
                
                    tic
                    [properImage, inliersTotal] = geometricalCheck(It, BoTW, params, candidates, visualData); 
                    timer.geometricalVerification(It, 1) = toc;
                
                    if properImage ~= 0
                        matches.loopClosureMatrix(It, properImage) = true; 
                        matches.matches(It, 1) = properImage;
                        matches.matches(It, 2) = probability; 
                        matches.inliers(It) = inliersTotal;
                    end
                end
           end            
        end 
        
        if params.queryingDatabase.save
            save('results/queryingDatabase', 'matches');
        end
        
    end    
end
