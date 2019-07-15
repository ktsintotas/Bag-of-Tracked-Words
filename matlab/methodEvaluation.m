function results = methodEvaluation(params, matches, groundTruthMatrix) 

%% Method Evaluation

    results = zeros(1, 6);
    
    if params.verification == true
        loopClosureMatrix = matches.loopClosureMatrixRANSAC;
    else
        loopClosureMatrix = matches.loopClosureMatrix;
    end

    if params.visualizationResults == true
        figure('IntegerHandle','on','Name','Loop Closure Matrix');
        spy(loopClosureMatrix);
    end
    
    if params.visualizationResults == true
        figure('IntegerHandle','on','Name','Ground Truth Matrix');
        spy(groundTruthMatrix);
    end

    % calculation the sum of true positives
    groundTruthNumber = sum(sum(groundTruthMatrix')>0);

    % calculation of True Positives
    % logical AND between ground truth and loop closure matrix for true positives
    tempTP = logical (groundTruthMatrix.*loopClosureMatrix); 
    tempSumTP = sum(tempTP, 2);
    truePositives = sum(tempSumTP, 1);
    if params.visualizationResults == true
        figure('IntegerHandle','on','Name','True Positives');
        spy(tempTP);
    end

    % calculation of False Positives
    % logical AND between opposite ground truth and loop closure matrix for false positives 
    tempFP = logical (loopClosureMatrix.* not(groundTruthMatrix)); 
    tempSumFP = sum(tempFP, 2);
    falsePositives = sum(tempSumFP, 1);
    if params.visualizationResults == true    
        figure('IntegerHandle','on','Name','False Positives');
        spy(tempFP);
    end

    % calculation of Precision - Recall 
    precisionScore = truePositives / (truePositives + falsePositives);
    recallScore = truePositives / groundTruthNumber;

    % Results
    results(1, 1) = precisionScore;
    results(1, 2) = recallScore;   
    results(1, 3) = truePositives;   
    results(1, 4) = falsePositives;
    results(1, 5) = params.probabilityThreshold;
    results(1, 6) = groundTruthNumber;
end