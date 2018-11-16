function [hdr, X, stateVector, N, SignalData, t] = FeatureExtraction(pathedf, pathtext)
addpath Function

disp('Loading Hypnograms...')
Data = AnnotExtract(pathtext);
stateEdge_t = Data(1, :);
state = Data(2, :);
disp('Done');


disp('Loading Signals...')
[hdr, records] = edfread(pathedf);
disp('Done');


disp('Filtering Frequency Bands...')
h_alpha = BPF (1001, 8  , 15, 100);
h_beta  = BPF (1001, 16 , 31, 100);
h_theta = BPF (1001, 4  ,  7, 100);
h_delta = BPF (1001, 0.5,  4, 100);
 
Fpz = records(1,1:end);
Oz  = records(2,1:end);
EOG = records(3,1:end);
EMG = records(4,1:end);
SignalData = [Fpz; Oz; EOG; EMG];
Fpz_alpha = filter(h_alpha, 1, Fpz);
Fpz_beta  = filter(h_beta , 1, Fpz);
Fpz_theta = filter(h_theta, 1, Fpz);
Fpz_delta = filter(h_delta, 1, Fpz);

Oz_alpha  = filter(h_alpha, 1, Oz);
Oz_beta   = filter(h_beta , 1, Oz);
Oz_theta  = filter(h_theta, 1, Oz);
Oz_delta  = filter(h_delta, 1, Oz);
disp('Done')


% Data Matrix
winEdges = [];
k = 1;
for j = 1 : 1000 : length(Fpz)-999
    X(k,1) = norm(Fpz_delta(j : j+999), 2).^2/1000;
    X(k,2) = norm(Fpz_theta(j : j+999), 2).^2/1000;
    X(k,3) = norm(Fpz_alpha(j : j+999), 2).^2/1000;
    X(k,4) = norm(Fpz_beta (j : j+999), 2).^2/1000;

    X(k,5) = norm(Oz_delta(j : j+999), 2).^2/1000;
    X(k,6) = norm(Oz_theta(j : j+999), 2).^2/1000;
    X(k,7) = norm(Oz_alpha(j : j+999), 2).^2/1000;
    X(k,8) = norm(Oz_beta (j : j+999), 2).^2/1000;
    
    X(k,9)  = norm(EOG (j : j+999), 2).^2/1000;
    X(k,10) = norm(EMG (j : j+999), 2).^2/1000;
    
    
    k = k + 1;
    winEdges = [winEdges, j];    
end

stateEdges_points  = 1 + 100*stateEdge_t;
stateEdges_points1 = [0, stateEdges_points];
diff = [stateEdges_points,0] - stateEdges_points1;
diff = diff(2:end-1);
state_NumBins = diff/1000;
stateVector = [];
for i = 1 : length(state_NumBins)
    stateVector = [stateVector, repmat(state(i), [1, state_NumBins(i)] )];
end
stateVector = [stateVector, repmat(  state(end), [1, length(winEdges) - length(stateVector) ])];

disp('Finding valid time interval...');
for i = 2 : length(X)
    if X(i, :) == X(i-1, :);
        N = i-100; 
        break
    end
end
disp('Done');

t = 10:10:length(Fpz)/100;

disp('Featue Extraction Completed.');
