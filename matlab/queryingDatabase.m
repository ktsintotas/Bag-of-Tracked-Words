function matches = queryingDatabase(params, visualData, BoTW)

    if params.queryingDatabase.load == true && exist('results/queryingDatabase.mat', 'file')    
        load('results/queryingDatabase.mat');
        
    else
        
        matches.votesMatrix = zeros(visualData.imagesLoaded, visualData.imagesLoaded, 'int16');                
        matches.binomialMatrix = zeros(visualData.imagesLoaded, visualData.imagesLoaded);        
        matches.loopClosureMatrix = false(visualData.imagesLoaded, visualData.imagesLoaded);
        matches.loopClosureMatrixRANSAC = false(visualData.imagesLoaded, visualData.imagesLoaded);
        matches.matches = zeros(visualData.imagesLoaded, 1, 'int16');
        matches.matchesRANSAC = zeros(visualData.imagesLoaded, 1, 'int16');
        
        for It = int16(1 : visualData.imagesLoaded)    
            disp(It);
            
            % B.1 MAP VOTING
            % indicating the vocabulary area which would be avoided  
            lastDatabaseLocation = It - 2 * BoTW.maximumActivePoint(It);
            if lastDatabaseLocation > 0
                databaseIndexTemp = single(find(BoTW.twIndex(:, 2) <= lastDatabaseLocation));                                
                if ~isempty(databaseIndexTemp)
                    databaseIndexTemp = databaseIndexTemp(end);
                    % visual vocabulary to be searched
                    database = BoTW.bagOfTrackedWords(1 : databaseIndexTemp, :); 
                    % indexing of bag of tracked words to be searched
                    databaseIndex = BoTW.twIndex(1 : databaseIndexTemp, :); 
                else
                     database = single([]);
                end
            end
            
            % vote aggregation
            if ~isempty(database)                
                % preparing Bag of Tracked Words for k-NN search
                database = ExhaustiveSearcher(database);
                % k-NN search 
                queryIdxNN = single(knnsearch(database, BoTW.queryDescriptors{It}, 'K', 1 ));                                      
                % location's points and descriptors based on voted tracked words
                locationPoints = cell(1, lastDatabaseLocation);                
                locationDescriptors = cell(1, lastDatabaseLocation);
                % voting through Nearest Neighbor Tracked Word
                for v = int16(1 : length(queryIdxNN))
                    % votes' distribution
                    matches.votesMatrix(It, databaseIndex(queryIdxNN(v), 1) : databaseIndex(queryIdxNN(v), 2)) = ...
                        matches.votesMatrix(It, databaseIndex(queryIdxNN(v), 1) : databaseIndex(queryIdxNN(v), 2)) + 1;
                    % locations' points and descriptor accosiation
                    count = int16(0);                     
                    for d = int16(databaseIndex(queryIdxNN(v), 1) : databaseIndex(queryIdxNN(v), 2))
                        count = count +1;                         
                        locationPoints{d} = [locationPoints{d} ;  BoTW.trackedWordPoints{queryIdxNN(v)}(count, :)];
                        locationDescriptors{d} = [locationDescriptors{d} ; BoTW.trackedWordDescriptors{queryIdxNN(v)}(count, :)]; 
                    end
                end
                % compute binomial for voted images
                imagesForBinomial = int16(find(matches.votesMatrix(It, :) >= 10));
                                
                % B.2 PROBABILISTIC BELIEF GENERATOR                
                % locations which pass the two conditions
                candidateLocations = zeros(1, lastDatabaseLocation, 'int16');
                % number of Tracked Words within the searching area 
                LAMDA = databaseIndexTemp;
                % number of query’s Tracked Points (number of points after the guided feature-detection)
                N = size(BoTW.queryDescriptors{It}, 1);                
                % probability computation for the selected images in the database
                for L = 1 : length(imagesForBinomial)
                    location = imagesForBinomial(L);
                    % number of accumulated votes of database location
                    xl = matches.votesMatrix(It, location);
                    p = single(BoTW.lamda(location)) / LAMDA;
                    expectedValue = N*p;
                    locationProbability = binopdf(xl, N , p);
                    % in order to plot binomial matrix <-- use it without -imagesForBinomial- threshold
                    matches.binomialMatrix(It, location) = locationProbability;
                    % the binomial expected value on each location has to
                    % satisfy two conditions, loop closure threshold and xl(t) > E [Xi(t)]
                    if locationProbability <  params.probabilityThreshold && xl > expectedValue
                        candidateLocations(location) = matches.votesMatrix(It, location);
                    end
                end
                
                % define the appropriate loop closing image for the image which gathers the most votes
                [votes, properImage] = max(candidateLocations);
                
                % geometric check yes or no?
                if votes ~= 0 && params.verification == true
                    indexPairs = matchFeatures(BoTW.queryDescriptors{It}, locationDescriptors{properImage}, 'Unique', true);
                    matchedPoints1 = BoTW.queryPoints{It}(indexPairs(:, 1), :);
                    matchedPoints2 = locationPoints{properImage}(indexPairs(:, 2), :);
                    try
                        [~, inliersIndex, ~] = estimateFundamentalMatrix(matchedPoints1, matchedPoints2, 'Method', 'RANSAC', 'DistanceThreshold', 1);                    
                        if sum(inliersIndex) >= params.inliersTheshold            
                            matches.loopClosureMatrixRANSAC(It, properImage) = true; 
                            matches.matchesRANSAC(It) = properImage;
                        end                        
                    catch
                        continue
                    end                    
                elseif votes ~= 0 && params.verification == false
                    matches.loopClosureMatrix(It, properImage) = true;
                    matches.matches(It) = properImage;
                end                
           end            
        end 
        
        if params.queryingDatabase.save
            save('results/queryingDatabase', 'matches');
        end        
    end    
end