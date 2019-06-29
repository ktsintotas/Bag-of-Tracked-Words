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

function BoTW = buildingDatabase(visualData, params)

    % shall we load the visual information and its' extracted variables?
    if params.buildingDatabase.load == true && exist('results/buildingDatabase.mat', 'file')    
        load('results/buildingDatabase.mat'); 
    
    else       

        % initialization of points' tracking validity based on our conditions
        trackObservation = false(params.numPointsToTrack, 1);
        % initialization of points' representation along consecutive features
        pointRepeatability = ones(params.numPointsToTrack, 1, 'int16');    
        
        twCounter = single(0);
        
        % visual dictionary
        BoTW.bagOfTrackedWords = single([]);
        % tracked words' indexing
        BoTW.twIndex = int16([]);
        % lamda is counting the number of tracked words belonging to the traversed location
        BoTW.lamda = zeros(1, size(visualData.inputImage, 2), 'int16');
        % maximum active point variable for the query process
        BoTW.maximumActivePoint = zeros(1, size(visualData.inputImage, 2), 'int16');
        % query points
        BoTW.queryPoints = cell(1, visualData.imagesLoaded);
        % query descriptors
        BoTW.queryDescriptors = cell(1, visualData.imagesLoaded);

        for It = int16(1 : visualData.imagesLoaded)
            
            % initialization of points and descriptors   
            if It == 1
                
                if size(visualData.pointsSURF{It}, 1) > params.numPointsToTrack
                    % initial query points and initial points for the tracker
                    BoTW.queryPoints{It}= visualData.pointsSURF{It}.Location(1 : params.numPointsToTrack, :);
                    % initial points, each one into a cell bag
                    trackedPointsBag = mat2cell(BoTW.queryPoints{It}, ones(1, params.numPointsToTrack));
                    % initial query descriptors
                    BoTW.queryDescriptors{It} = visualData.featuresSURF{It}(1 : params.numPointsToTrack, :);
                    % initial descriptors, each one into a cell bag
                    trackedDescriptorsBag = mat2cell(BoTW.queryDescriptors{It}, ones(1, params.numPointsToTrack));
                else 
                    BoTW.queryPoints{It}= visualData.pointsSURF{It}.Location(1 : size(visualData.pointsSURF{It}, 1), :);
                    trackedPointsBag = mat2cell(trackedPointsBag, ones(1, size(visualData.pointsSURF{It}, 1)));                   
                    BoTW.queryDescriptors{It} = visualData.featuresSURF{It}(1 : size(visualData.featuresSURF{It}, 1), :);
                    trackedDescriptorsBag = mat2cell(BoTW.queryDescriptors{It}, ones(1, size(visualData.featuresSURF{It}, 1)));
                end    

                % point tracker object generation that tracks a set of points
                pointTracker = vision.PointTracker('NumPyramidLevels', 3, 'MaxBidirectionalError', 3); 
                initialize(pointTracker, BoTW.queryPoints{It}, visualData.inputImage{It});
                
            end
            
            if It > 1            
                % I(t-1)
                previousIt = int16(It-1);
                if It > 2                
                    % objects lock when you call them and the release function unlocks them
                    release(pointTracker); 
                    % initialize again the tracker with the new and more accurate points            
                    initialize(pointTracker, BoTW.queryPoints{previousIt}, visualData.inputImage{previousIt}); 
                end

                % A.1 POINT TRACKING
                % tracked points in the incoming frame
                [trackedPoints, trackedPointsValidity] = pointTracker(visualData.inputImage{It}); 

                % A.2 GUIDED GEATURE DETECTION             
                [BoTW.queryPoints{It}, BoTW.queryDescriptors{It}, pointRepeatability, trackObservation, pointsToSearch, descriptorsToSearch, trackedPointsBag, trackedDescriptorsBag] = ... 
                    guidedFeatureDetection(params, visualData, previousIt, It, BoTW.queryPoints{previousIt}, BoTW.queryDescriptors{previousIt}, trackedPoints, trackedPointsValidity, pointRepeatability, trackedPointsBag, trackedDescriptorsBag, trackObservation);

                % A.3 BAG OF TRACKED WORDS
                newPointCounter = int16(0);
                deletion = false;
                pointsToDelete = false(length(trackObservation), 1);                
                for tw = int16(1 : params.numPointsToTrack)
                    % When the tracking of a certain point is discontinued, its total length measured in consecutive frames, determines whether a new word should be created
                    if trackObservation(tw) == false && pointRepeatability(tw) > params.trackLength 
                        twCounter =  twCounter + 1;
                        % Bag of Tracked Words generation from the average of the tracked descriptors the representative TW is computed
                        BoTW.bagOfTrackedWords(twCounter, :) = mean(trackedDescriptorsBag{tw}, 1 );
                        % first image where the point is observed //BoTW.twIndex(twCounter, 1) = It - pointRepeatability(tw);
                        % last image where the feature is observed // BoTW.twIndex(twCounter, 2) = previous;
                        % tracked word's repeatability // BoTW.twIndex(twCounter, 3)
                        BoTW.twIndex(twCounter, :) = [(It - pointRepeatability(tw)), previousIt, pointRepeatability(tw)];
                        % points correspond to the generated tracked word
                        BoTW.trackedWordPoints{twCounter} = trackedPointsBag{tw};
                        % descriptors correspond to the generated tracked word
                        BoTW.trackedWordDescriptors{twCounter} = trackedDescriptorsBag{tw};                
                        % how many tracked words each location generates
                        BoTW.lamda(1, BoTW.twIndex(twCounter, 1) : BoTW.twIndex(twCounter, 2)) =  BoTW.lamda(1, BoTW.twIndex(twCounter, 1) : BoTW.twIndex(twCounter, 2)) + 1;
                    end
                    % replacement of point that either became TW or just lose its track
                    if trackObservation(tw) == false && newPointCounter < size(pointsToSearch, 1)
                        newPointCounter = newPointCounter + 1;
                        % new point addition
                        BoTW.queryPoints{It}(tw, :) = pointsToSearch(newPointCounter, : );
                        % new query descriptor addition
                        BoTW.queryDescriptors{It}(tw, :) = descriptorsToSearch(newPointCounter, : );
                        % new point addition
                        trackedPointsBag{tw} = pointsToSearch(newPointCounter, : );
                        % new descriptor addition
                        trackedDescriptorsBag{tw} = descriptorsToSearch(newPointCounter, : );
                        % initialization new point representation
                        pointRepeatability(tw) = 1; 
                    % in cases where the plane is not textured enough
                    elseif trackObservation(tw) == false && newPointCounter >= size(pointsToSearch, 1) 
                    	deletion = true;
                        pointsToDelete(tw) = true;                        
                    end
                end    
                if deletion == true
                    BoTW.queryPoints{It}((pointsToDelete == true), :) = [];
                    BoTW.queryDescriptors{It}((pointsToDelete == true), :) = [];
                    trackedPointsBag((pointsToDelete == true), :) = [];
                    trackedDescriptorsBag((pointsToDelete == true), :) = [];
                    pointRepeatability((pointsToDelete == true), :) = [];
                    pointRepeatability(length(pointRepeatability) + 1 : params.numPointsToTrack) = 1;
                end
           
                BoTW.maximumActivePoint(It) = max(pointRepeatability);
                
            end
        end
        
        % save the generated database if not a file exists
        if params.buildingDatabase.save
            save('results/buildingDatabase', 'BoTW', '-v7.3');
        end
        
    end
end