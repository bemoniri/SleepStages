function [trainedClassifier, validationAccuracy, partitionedModel] = REMWAKEtrainClassifier(trainingData)

inputTable = trainingData;
predictorNames = {'FpzDelta', 'FpzTheta', 'FpzAlpha', 'FpzBeta', 'OzDelta', 'OzTheta', 'OzAlpha', 'OzBeta', 'EOGPower', 'EMGPower'};
predictors = inputTable(:, predictorNames);
response = inputTable.State;
isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false];

% Train a classifier
% This code specifies all the classifier options and trains the classifier.
classificationSVM = fitcsvm(...
    predictors, ...
    response, ...
    'KernelFunction', 'linear', ...
    'PolynomialOrder', [], ...
    'KernelScale', 'auto', ...
    'BoxConstraint', 1, ...
    'Standardize', true, ...
    'ClassNames', [0; 6]);

% Create the result struct with predict function
predictorExtractionFcn = @(t) t(:, predictorNames);
svmPredictFcn = @(x) predict(classificationSVM, x);
trainedClassifier.predictFcn = @(x) svmPredictFcn(predictorExtractionFcn(x));

% Add additional fields to the result struct
trainedClassifier.RequiredVariables = {'FpzDelta', 'FpzTheta', 'FpzAlpha', 'FpzBeta', 'OzDelta', 'OzTheta', 'OzAlpha', 'OzBeta', 'EOGPower', 'EMGPower'};
trainedClassifier.ClassificationSVM = classificationSVM;
trainedClassifier.About = 'This struct is a trained classifier exported from Classification Learner R2016a.';
trainedClassifier.HowToPredict = sprintf('To make predictions on a new table, T, use: \n  yfit = c.predictFcn(T) \nreplacing ''c'' with the name of the variable that is this struct, e.g. ''trainedClassifier''. \n \nThe table, T, must contain the variables returned by: \n  c.RequiredVariables \nVariable formats (e.g. matrix/vector, datatype) must match the original training data. \nAdditional variables are ignored. \n \nFor more information, see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ''appclassification_exportmodeltoworkspace'')">How to predict using an exported model</a>.');

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
