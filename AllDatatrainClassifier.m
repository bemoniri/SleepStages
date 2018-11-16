function [trainedClassifier, validationAccuracy, partitionedModel] = AllDatatrainClassifier(trainingData)

inputTable = trainingData;
predictorNames = {'FpzDelta', 'FpzTheta', 'FpzAlpha', 'FpzBeta', 'OzDelta', 'OzTheta', 'OzAlpha', 'OzBeta', 'EOGPower', 'EMGPower'};
predictors = inputTable(:, predictorNames);
response = inputTable.State;
isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false];

% Train a classifier
% This code specifies all the classifier options and trains the classifier.
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
    'ClassNames', [0; 1; 2; 3; 4; 6]);

% Create the result struct with predict function
predictorExtractionFcn = @(t) t(:, predictorNames);
svmPredictFcn = @(x) predict(classificationSVM, x);
trainedClassifier.predictFcn = @(x) svmPredictFcn(predictorExtractionFcn(x));

% Add additional fields to the result struct
trainedClassifier.RequiredVariables = {'FpzDelta', 'FpzTheta', 'FpzAlpha', 'FpzBeta', 'OzDelta', 'OzTheta', 'OzAlpha', 'OzBeta', 'EOGPower', 'EMGPower'};
trainedClassifier.ClassificationSVM = classificationSVM;

% Extract predictors and response
% This code processes the data into the right shape for training the
% classifier.
inputTable = trainingData;
predictorNames = {'FpzDelta', 'FpzTheta', 'FpzAlpha', 'FpzBeta', 'OzDelta', 'OzTheta', 'OzAlpha', 'OzBeta', 'EOGPower', 'EMGPower'};
predictors = inputTable(:, predictorNames);
response = inputTable.State;
isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false];

% Perform cross-validation
partitionedModel = crossval(trainedClassifier.ClassificationSVM, 'KFold', 5);

% Compute validation accuracy
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError')

% Compute validation predictions and scores
[validationPredictions, validationScores] = kfoldPredict(partitionedModel);
