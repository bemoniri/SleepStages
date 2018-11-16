clc
clear
close all
load('./Data/SubjectData.mat')

SubjectNumber = '1';   % Subject number
edf  = Subjects(str2double(SubjectNumber)).edf;
text = Subjects(str2double(SubjectNumber)).text;

[hdr, X, state, N, SignalData, t] = FeatureExtraction(edf, text);

% state = state of sleep in each 10 second interval
% X     = The main data file
% hdr   = Info provided in the header of edf files
% N     = The last valid 10 second interval
% t     = 10 Second intervals end time

% SignalData = EEG EMG EOG Data Matrix


fullTable = table(X(:,1),X(:,2),X(:,3),X(:,4),X(:,5),X(:,6),X(:,7),X(:,8),X(:,9),X(:,10),state','VariableNames',...
    {'FpzDelta','FpzTheta','FpzAlpha', 'FpzBeta', 'OzDelta','OzTheta','OzAlpha', 'OzBeta', 'EOGPower', 'EMGPower', 'State'});


Table = fullTable(1:N,:);   % Used in linear model function
Data = X(1:N, :);           

%% Section 3 - PCA
Data_Centered = Data - repmat(mean(Data, 1), N,1);

[PCA.coeffs, PCA.score, PCA.latent] = pca(Data_Centered);

figure

plot(cumsum(PCA.latent)./sum(PCA.latent))
xlabel('Number of Eigenvectors'); ylabel('Cummalative Density');
title(['Subject ', SubjectNumber])
PCA.Data   = Table{:,1:10}*PCA.coeffs;
PCA.state0 = Table{Table.State==0,1:10}*PCA.coeffs;
PCA.state1 = Table{Table.State==1,1:10}*PCA.coeffs;
PCA.state2 = Table{Table.State==2,1:10}*PCA.coeffs;
PCA.state3 = Table{Table.State==3,1:10}*PCA.coeffs;
PCA.state4 = Table{Table.State==4,1:10}*PCA.coeffs;
PCA.state6 = Table{Table.State==6,1:10}*PCA.coeffs;

figure
plot3(PCA.state0(:,1), PCA.state0(:,2), PCA.state0(:,3),'.')
hold on
grid on
plot3(PCA.state1(:,1), PCA.state1(:,2), PCA.state1(:,3),'.')
plot3(PCA.state2(:,1), PCA.state2(:,2), PCA.state2(:,3),'.')
plot3(PCA.state3(:,1), PCA.state3(:,2), PCA.state3(:,3),'.')
plot3(PCA.state4(:,1), PCA.state4(:,2), PCA.state4(:,3),'.')
plot3(PCA.state6(:,1), PCA.state6(:,2), PCA.state6(:,3),'.')

xlabel('PC1'); ylabel('PC2'); zlabel('PC3');
zlim([-100,500]); ylim([-500,800]); xlim([-100,10000]);
legend('W', '1', '2', '3', '4', 'REM')
title(['Subject ', SubjectNumber])

%% Wake and REM
figure

plot3(PCA.state0(:,1), PCA.state0(:,2), PCA.state0(:,3),'.')
hold on
grid on
plot3(PCA.state6(:,1), PCA.state6(:,2), PCA.state6(:,3),'.')

xlabel('PC1'); ylabel('PC2'); zlabel('PC3');
zlim([-100,500]); ylim([-500,800]); xlim([-100,10000]);
legend('Wake', 'REM')
title(['Subject ', SubjectNumber])

figure
subplot(311)
hold on
t1 = -100: 100 : 4000;
histogram(PCA.state0(:,1), 'BinEdges', t1, 'Normalization', 'pdf')
histogram(PCA.state6(:,1), 'BinEdges', t1, 'Normalization', 'pdf')
ylabel('PC1');
legend('Wake', 'REM');

subplot(312)
t2 = -1000:40:1000;
hold on
histogram(PCA.state0(:,2), 'BinEdges', t2, 'Normalization', 'pdf')
histogram(PCA.state6(:,2), 'BinEdges', t2, 'Normalization', 'pdf')
ylabel('PC2');
legend('Wake', 'REM');

subplot(313)
t3 = -100:4:100;
hold on
histogram(PCA.state0(:,3), 'BinEdges', t3, 'Normalization', 'pdf')
histogram(PCA.state6(:,3), 'BinEdges', t3, 'Normalization', 'pdf')
ylabel('PC1');
legend('Wake', 'REM');

%% Non-REM

figure
plot3(PCA.state1(:,1), PCA.state1(:,2), PCA.state1(:,3),'.')
hold on
grid on
plot3(PCA.state2(:,1), PCA.state2(:,2), PCA.state2(:,3),'.')
plot3(PCA.state3(:,1), PCA.state3(:,2), PCA.state3(:,3),'.')
plot3(PCA.state4(:,1), PCA.state4(:,2), PCA.state4(:,3),'.')

xlabel('PC1'); ylabel('PC2'); zlabel('PC3');
zlim([-100,500]); ylim([-500,800]); xlim([-100,10000]);
legend('1', '2', '3', '4')
title(['Subject ', SubjectNumber])

figure
subplot(311)
hold on
t1 = -100: 50 : 4000;
histogram(PCA.state1(:,1), 'BinEdges', t1, 'Normalization', 'pdf')
histogram(PCA.state2(:,1), 'BinEdges', t1, 'Normalization', 'pdf')
histogram(PCA.state3(:,1), 'BinEdges', t1, 'Normalization', 'pdf')
histogram(PCA.state4(:,1), 'BinEdges', t1, 'Normalization', 'pdf')
ylabel('PC1');
legend('1', '2', '3', '4');

subplot(312)
t2 = -200:5:150;
hold on
histogram(PCA.state1(:,2), 'BinEdges', t2, 'Normalization', 'pdf')
histogram(PCA.state2(:,2), 'BinEdges', t2, 'Normalization', 'pdf')
histogram(PCA.state3(:,2), 'BinEdges', t2, 'Normalization', 'pdf')
histogram(PCA.state4(:,2), 'BinEdges', t2, 'Normalization', 'pdf')
ylabel('PC2');
legend('1', '2', '3', '4');

subplot(313)
t3 = -50:4:300;
hold on
histogram(PCA.state1(:,3), 'BinEdges', t3, 'Normalization', 'pdf')
histogram(PCA.state2(:,3), 'BinEdges', t3, 'Normalization', 'pdf')
histogram(PCA.state3(:,3), 'BinEdges', t3, 'Normalization', 'pdf')
histogram(PCA.state4(:,3), 'BinEdges', t3, 'Normalization', 'pdf')
ylabel('PC3');
legend('1', '2', '3', '4');


%% All States

figure
subplot(311)
hold on
t1 = -100: 40 : 4000;
histogram(PCA.state0(:,1), 'BinEdges', t1, 'Normalization', 'pdf')
histogram(PCA.state1(:,1), 'BinEdges', t1, 'Normalization', 'pdf')
histogram(PCA.state2(:,1), 'BinEdges', t1, 'Normalization', 'pdf')
histogram(PCA.state3(:,1), 'BinEdges', t1, 'Normalization', 'pdf')
histogram(PCA.state4(:,1), 'BinEdges', t1, 'Normalization', 'pdf')
histogram(PCA.state6(:,1), 'BinEdges', t1, 'Normalization', 'pdf')

ylabel('PC1');
legend('Wake','1', '2', '3', '4','REM');

subplot(312)
hold on
t2 = -300:10:300;
histogram(PCA.state0(:,2), 'BinEdges', t2, 'Normalization', 'pdf')
histogram(PCA.state1(:,2), 'BinEdges', t2, 'Normalization', 'pdf')
histogram(PCA.state2(:,2), 'BinEdges', t2, 'Normalization', 'pdf')
histogram(PCA.state3(:,2), 'BinEdges', t2, 'Normalization', 'pdf')
histogram(PCA.state4(:,2), 'BinEdges', t2, 'Normalization', 'pdf')
histogram(PCA.state6(:,2), 'BinEdges', t2, 'Normalization', 'pdf')
ylabel('PC2');

subplot(313)
t3 = -500:10:400;

hold on
histogram(PCA.state0(:,2), 'BinEdges', t3, 'Normalization', 'pdf')
histogram(PCA.state1(:,2), 'BinEdges', t3, 'Normalization', 'pdf')
histogram(PCA.state2(:,2), 'BinEdges', t3, 'Normalization', 'pdf')
histogram(PCA.state3(:,2), 'BinEdges', t3, 'Normalization', 'pdf')
histogram(PCA.state4(:,2), 'BinEdges', t3, 'Normalization', 'pdf')
histogram(PCA.state6(:,2), 'BinEdges', t3, 'Normalization', 'pdf')
ylabel('PC3');

clear t t1 t2 t3 
%% Section 4 - Linear Model

SleepDepthTable = Table(Table.State == 1 |Table.State == 2 |Table.State == 3 |Table.State == 4 , :);

LinearModel = fitlm(SleepDepthTable)

Regression.state1 = LinearModel.Fitted(SleepDepthTable.State == 1);
Regression.state2 = LinearModel.Fitted(SleepDepthTable.State == 2);
Regression.state3 = LinearModel.Fitted(SleepDepthTable.State == 3);
Regression.state4 = LinearModel.Fitted(SleepDepthTable.State == 4);

t = 0:0.1:5;
figure
hold on
histogram(Regression.state1, 'BinEdges', t, 'Normalization', 'pdf')
histogram(Regression.state2, 'BinEdges', t, 'Normalization', 'pdf')
histogram(Regression.state3, 'BinEdges', t, 'Normalization', 'pdf')
histogram(Regression.state4, 'BinEdges', t, 'Normalization', 'pdf')
legend('State1' , 'State2', 'State3', 'State4');
xlim([-1,6])

%% Cross Validation

% Error of classification by using all variables
vars = 1:11;
SleepDepth = SleepDepthTable(:, vars);
s = size(SleepDepth);
I = randperm(s(1));
TestData  = I(1: floor(s(1)/5));
TrainData = I(floor(s(1)/5) + 1: s(1));

TrainTable = SleepDepth(TrainData, :);
TestTable  = SleepDepth(TestData, :);
cValLinearModel = fitlm(TrainTable)
predict = cValLinearModel.predict(TestTable{:, vars(1:end-1)});
E = norm(predict-TestTable{:, end})

% Excluding one variable and calculating error
exc = [2 3 4 5 6 7 8 9 10 11; 1 3 4 5 6 7 8 9 10 11;1 2 4 5 6 7 8 9 10 11;1 2 3  5 6 7 8 9 10 11;1 2 3 4  6 7 8 9 10 11;1 2 3 4 5  7 8 9 10 11; ...
    1 2 3 4 5 6  8 9 10 11; 1 2 3 4 5 6 7  9 10 11; 1 2 3 4 5 6 7 8 10 11; 1 2 3 4 5 6 7 8 9 11]; % Which variables to include
    clear Cross_MEAN Cross_STD vars  crit
for j = 1 : 10
    vars = exc(j, :);
    clear crit
    for i = 1 : 100
        SleepDepth = SleepDepthTable(:, vars);
        s = size(SleepDepth);
        I = randperm(s(1));
        TestData  = I(1: floor(s(1)/5));
        TrainData = I(floor(s(1)/5) + 1: s(1));

        TrainTable = SleepDepth(TrainData, :);
        TestTable  = SleepDepth(TestData, :);

         cValLinearModel = fitlm(TrainTable);
         predict = cValLinearModel.predict(TestTable{:, vars(1:end-1)});
         crit(i) = norm(predict-TestTable{:, end});
    end
    Cross_MEAN(j) = mean(100*(crit-E)/E);
end
Cross_MEAN(j) = mean(100*(crit-E)/E)
clear predict Cross_MEAN crit TrainTable TestTable I s cValLinearModel vars exc i j

%% Section 4 - Linear Model's Prediction for Wake and REM

Regression.Wake_predict = LinearModel.predict(Table{Table.State == 0, 1:10});
Regression.REM_predict  = LinearModel.predict(Table{Table.State == 6, 1:10});

figure
hold on
histogram(Regression.state1, 'BinEdges', t, 'Normalization', 'pdf')
histogram(Regression.state2, 'BinEdges', t, 'Normalization', 'pdf')
histogram(Regression.state3, 'BinEdges', t, 'Normalization', 'pdf')
histogram(Regression.state4, 'BinEdges', t, 'Normalization', 'pdf')
histogram(Regression.Wake_predict,'BinEdges', t, 'Normalization', 'pdf')
histogram(Regression.REM_predict,'BinEdges', t, 'Normalization', 'pdf')
legend('State 1', 'State 2', 'State 3', 'State 4','Wake', 'REM');
xlim([-1,6])

figure
hold on
histogram(Regression.Wake_predict,'BinEdges', t, 'Normalization', 'pdf')
histogram(Regression.REM_predict,'BinEdges', t, 'Normalization', 'pdf')
legend('Wake', 'REM');
xlim([-1,4])

%% Section 5 - NREM SVM

[trainedClassifier, validationAccuracy, partitionedModel] = DepthtrainClassifier(SleepDepthTable);
[validationPredictions, validationScores] = kfoldPredict(partitionedModel);
confmat = confusionmat(SleepDepthTable{:,11},validationPredictions)
 

%% All Data SVM
[trainedClassifier, validationAccuracy, partitionedModel] = AllDatatrainClassifier(Table);
[validationPredictions, validationScores] = kfoldPredict(partitionedModel);
confmat = confusionmat(Table{:,11},validationPredictions)
 
%% REM and Wake SVM
REMWAKE = Table(Table.State == 0 |Table.State == 6, :);
[trainedClassifier, validationAccuracy, partitionedModel] = REMWAKEtrainClassifier(REMWAKE);
[validationPredictions, validationScores] = kfoldPredict(partitionedModel);
confmat = confusionmat(REMWAKE{:,11}, validationPredictions)
 