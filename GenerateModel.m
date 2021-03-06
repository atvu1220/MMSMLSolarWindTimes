function [trainedClassifier, validationAccuracy] = GenerateModel(trainingData)
    % [trainedClassifier, validationAccuracy] = trainClassifier(trainingData)
    % returns a trained classifier and its accuracy. This code recreates the
    % classification model trained in Classification Learner app. Use the
    % generated code to automate training the same model with new data, or to
    % learn how to programmatically train models.
    %
    %  Input:
    %      trainingData: a table containing the same predictor and response
    %       columns as imported into the app.
    %
    %  Output:
    %      trainedClassifier: a struct containing the trained classifier. The
    %       struct contains various fields with information about the trained
    %       classifier.
    %
    %      trainedClassifier.predictFcn: a function to make predictions on new
    %       data.
    %
    %      validationAccuracy: a double containing the accuracy in percent. In
    %       the app, the History list displays this overall accuracy score for
    %       each model.
    %
    % Use the code to train the model with new data. To retrain your
    % classifier, call the function from the command line with your original
    % data or new data as the input argument trainingData.
    %
    % For example, to retrain a classifier trained with the original data set
    % T, enter:
    %   [trainedClassifier, validationAccuracy] = trainClassifier(T)
    %
    % To make predictions with the returned 'trainedClassifier' on new data T2,
    % use
    %   yfit = trainedClassifier.predictFcn(T2)
    %
    % T2 must be a table containing at least the same predictor columns as used
    % during training. For details, enter:
    %   trainedClassifier.HowToPredict
    
    % Auto-generated by MATLAB on 19-Aug-2019 04:53:53
    
    
    % Extract predictors and response
    % This code processes the data into the right shape for training the
    % model.
    inputTable = trainingData;
    predictorNames = {'Bx', 'By', 'Bz', 'Bmag', 'N', 'Vx', 'Vy', 'Vz', 'Vmag', 'Rx', 'Ry', 'Rz', 'R'};
    predictors = inputTable(:, predictorNames);
    response = inputTable.Response;
    isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false, false, false];
    
    % Data transformation: Select subset of the features
    % This code selects the same subset of features as were used in the app.
    includedPredictorNames = predictors.Properties.VariableNames([false false false true true true true true true false false false false]);
    predictors = predictors(:,includedPredictorNames);
    isCategoricalPredictor = isCategoricalPredictor([false false false true true true true true true false false false false]);
    
    % Train a classifier
    % This code specifies all the classifier options and trains the classifier.
    classificationTree = fitctree(...
        predictors, ...
        response, ...
        'PredictorSelection','curvature',...
        'SplitCriterion', 'gdi', ...
        'MaxNumSplits', 500, ...
        'Surrogate', 'all', ...
        'ClassNames', categorical({'Magnetosheath'; 'Solar Wind'; 'Magnetosphere'}, {'Magnetosheath' 'Solar Wind' 'Magnetosphere'}));
    
    % Create the result struct with predict function
    predictorExtractionFcn = @(t) t(:, predictorNames);
    featureSelectionFcn = @(x) x(:,includedPredictorNames);
    treePredictFcn = @(x) predict(classificationTree, x);
    trainedClassifier.predictFcn = @(x) treePredictFcn(featureSelectionFcn(predictorExtractionFcn(x)));
    
    % Add additional fields to the result struct
    trainedClassifier.RequiredVariables = {'Bx', 'By', 'Bz', 'Bmag', 'N', 'Vx', 'Vy', 'Vz', 'Vmag', 'Rx', 'Ry', 'Rz', 'R'};
    trainedClassifier.ClassificationTree = classificationTree;
    trainedClassifier.About = 'This struct is a trained model exported from Classification Learner R2018b.';
    trainedClassifier.HowToPredict = sprintf('To make predictions on a new table, T, use: \n  yfit = c.predictFcn(T) \nreplacing ''c'' with the name of the variable that is this struct, e.g. ''trainedModel''. \n \nThe table, T, must contain the variables returned by: \n  c.RequiredVariables \nVariable formats (e.g. matrix/vector, datatype) must match the original training data. \nAdditional variables are ignored. \n \nFor more information, see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ''appclassification_exportmodeltoworkspace'')">How to predict using an exported model</a>.');
    
    % Extract predictors and response
    % This code processes the data into the right shape for training the
    % model.
    inputTable = trainingData;
    predictorNames = {'Bx', 'By', 'Bz', 'Bmag', 'N', 'Vx', 'Vy', 'Vz', 'Vmag', 'Rx', 'Ry', 'Rz', 'R'};
    predictors = inputTable(:, predictorNames);
    response = inputTable.Response;
    isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false, false, false];
    
    % Perform cross-validation
    partitionedModel = crossval(trainedClassifier.ClassificationTree, 'KFold', 25);
    
    % Compute validation predictions
    [validationPredictions, validationScores] = kfoldPredict(partitionedModel);
    
    % Compute validation accuracy
    validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');
