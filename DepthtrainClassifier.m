function [trainedClassifier, validationAccuracy, partitionedModel] = DepthtrainClassifier(trainingData)

% Extract predictors and response

inputTable = trainingData;
predictorNames = {'FpzDelta', 'FpzTheta', 'FpzAlpha', 'FpzBeta', 'OzDelta', 'OzTheta', 'OzAlpha', 'OzBeta', 'EOGPower', 'EMGPower'};
predictors = inputTable(:, predictorNames);
response = inputTable.State;

template = templateSVM(...
    'KernelFunction', 'linear', ...
    'PolynomialOrder', [], ...
    'KernelScale', 'auto', ...
    'BoxConstraint', 1, ...
    'Standardize', true);
classificationSVM = fitcecoc(...
    predictors, ...
    response, ...
    'Learners', template, ...
    'Coding', 'onevsone', ...
    'ClassNames', [1; 2; 3; 4]);

% Create the result struct with predict function
predictorExtractionFcn = @(t) t(:, predictorNames);
svmPredictFcn = @(x) predict(classificationSVM, x);
trainedClassifier.predictFcn = @(x) svmPredictFcn(predictorExtractionFcn(x));

% Add additional fields to the result struct
trainedClassifier.RequiredVariables = {'FpzDelta', 'FpzTheta', 'FpzAlpha', 'FpzBeta', 'OzDelta', 'OzTheta', 'OzAlpha', 'OzBeta', 'EOGPower', 'EMGPower'};
trainedClassifier.ClassificationSVM = classificationSVM;

% Extract predictors and response
inputTable = trainingData;

predictors = inputTable(:, predictorNames);
response = inputTable.State;
isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false];

% Perform cross-validation
partitionedModel = crossval(trainedClassifier.ClassificationSVM, 'KFold', 5);

% Compute validation accuracy
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError')

% Compute validation predictions and scores
[validationPredictions, validationScores] = kfoldPredict(partitionedModel);
