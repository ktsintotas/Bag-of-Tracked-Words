function timer = timersInitialization(visualData, timer)

    %  memory allocation for timer for feature tracking
    timer.trackingPoints = zeros(visualData.imagesLoaded, 1,'single');
    % memory allocation for timer for guided feature selection
    timer.guidedFeatureSelection = zeros(visualData.imagesLoaded, 1,'single');
    % memory allocation for timer for brute force database search
    timer.databaseSearch = zeros(visualData.imagesLoaded, 1,'single');
    % memory allocation for timer for votes distribution
    timer.votesDistribution = zeros(visualData.imagesLoaded, 1,'single');
    % memory allocation for timer for binomial scoring
    timer.binomialScoring = zeros(visualData.imagesLoaded, 1,'single');
    % memory allocation for timer for geometrical verification 
    timer.geometricalVerification = zeros(visualData.imagesLoaded, 1,'single');    
    
end
