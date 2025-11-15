function results = train_test_scenario3(modality)
%% TRAIN_TEST_SCENARIO3 - Test Scenario 3: Combined data with 70/30 split
% =========================================================================
% This scenario combines data from both Day 1 and Day 2, then randomly
% splits into 70% training and 30% testing. This evaluates the system's
% performance when it has access to diverse data from multiple sessions.
%
% Input:
%   modality: 'accel', 'gyro', or 'combined'
%
% Output:
%   results: struct containing trained model, predictions, and test data
%
% Test Configuration:
%   - Training: Random 70% from combined Day 1 + Day 2 data
%   - Testing: Remaining 30% from combined data
%   - Stratified split to maintain class balance
%
% This scenario shows:
%   - Maximum performance potential with diverse training data
%   - How well the system performs with data from multiple sessions
%   - Provides upper bound on achievable accuracy
%
% Reference: Experimental setup requirement - Test 3
% =========================================================================

    fprintf('\n========================================================\n');
    fprintf('SCENARIO 3: Combined Data with 70/30 Split\n');
    fprintf('Modality: %s\n', upper(modality));
    fprintf('========================================================\n');
    
    %% Load and combine features from both days
    switch lower(modality)
        case 'accel'
            load('results/features_day1_accel.mat', 'features_d1_accel', 'labels_d1_accel');
            load('results/features_day2_accel.mat', 'features_d2_accel', 'labels_d2_accel');
            X = [features_d1_accel; features_d2_accel];
            y = [labels_d1_accel; labels_d2_accel];
        case 'gyro'
            load('results/features_day1_gyro.mat', 'features_d1_gyro', 'labels_d1_gyro');
            load('results/features_day2_gyro.mat', 'features_d2_gyro', 'labels_d2_gyro');
            X = [features_d1_gyro; features_d2_gyro];
            y = [labels_d1_gyro; labels_d2_gyro];
        case 'combined'
            load('results/features_day1_combined.mat', 'features_d1_combined', 'labels_d1_combined');
            load('results/features_day2_combined.mat', 'features_d2_combined', 'labels_d2_combined');
            X = [features_d1_combined; features_d2_combined];
            y = [labels_d1_combined; labels_d2_combined];
        otherwise
            error('Invalid modality. Choose: accel, gyro, or combined');
    end
    
    fprintf('Total samples (Day 1 + Day 2): %d\n', size(X, 1));
    fprintf('Number of features: %d\n', size(X, 2));
    fprintf('Number of users: %d\n', length(unique(y)));
    
    %% Display data distribution
    fprintf('\nData distribution by day:\n');
    fprintf('  Day 1 samples: %d\n', size(X, 1)/2);
    fprintf('  Day 2 samples: %d\n', size(X, 1)/2);
    
    %% Stratified Train/Test Split (70/30)
    fprintf('\nSplitting combined data (70%% train / 30%% test)...\n');
    
    rng(42); % For reproducibility
    cv = cvpartition(y, 'HoldOut', 0.30);
    
    trainIdx = training(cv);
    testIdx = test(cv);
    
    X_train = X(trainIdx, :);
    y_train = y(trainIdx);
    X_test = X(testIdx, :);
    y_test = y(testIdx);
    
    fprintf('Training samples: %d (70%%)\n', size(X_train, 1));
    fprintf('Testing samples: %d (30%%)\n', size(X_test, 1));
    
    %% Standardize Features
    fprintf('Standardizing features...\n');
    
    mu = mean(X_train);
    sigma = std(X_train);
    sigma(sigma == 0) = 1; % Avoid division by zero
    
    X_train_norm = (X_train - mu) ./ sigma;
    X_test_norm = (X_test - mu) ./ sigma;
    
    %% Prepare labels for neural network
    uniqueUsers = unique(y);
    numClasses = length(uniqueUsers);
    
    % Map user IDs to indices 1:numClasses
    labelMap = containers.Map(uniqueUsers, 1:numClasses);
    y_train_idx = zeros(size(y_train));
    y_test_idx = zeros(size(y_test));
    
    for i = 1:length(y_train)
        y_train_idx(i) = labelMap(y_train(i));
    end
    for i = 1:length(y_test)
        y_test_idx(i) = labelMap(y_test(i));
    end
    
    %% Build and Train Neural Network
    fprintf('\nBuilding neural network...\n');
    fprintf('  Architecture: [%d] -> [128, 64] -> [%d]\n', size(X_train_norm, 2), numClasses);
    
    hiddenLayerSize = [128, 64];
    net = patternnet(hiddenLayerSize, 'trainscg');
    
    % Configure training
    net.trainParam.epochs = 300;
    net.trainParam.showWindow = false;
    net.trainParam.showCommandLine = false;
    net.divideParam.trainRatio = 0.85;
    net.divideParam.valRatio = 0.15;
    net.divideParam.testRatio = 0;
    net.performFcn = 'crossentropy';
    
    fprintf('Training neural network on combined data...\n');
    
    % Transpose data for MATLAB's neural network format
    X_train_t = X_train_norm';
    y_train_onehot = full(ind2vec(y_train_idx'));
    
    % Train
    [net, tr] = train(net, X_train_t, y_train_onehot);
    
    fprintf('✓ Training complete!\n');
    
    %% Evaluate on Training Data
    y_train_pred = net(X_train_t);
    [~, y_train_pred_idx] = max(y_train_pred);
    trainAccuracy = sum(y_train_pred_idx' == y_train_idx) / length(y_train_idx) * 100;
    
    fprintf('\nTraining accuracy: %.2f%%\n', trainAccuracy);
    
    %% Evaluate on Test Data
    X_test_t = X_test_norm';
    y_test_pred = net(X_test_t);
    [~, y_test_pred_idx] = max(y_test_pred);
    testAccuracy = sum(y_test_pred_idx' == y_test_idx) / length(y_test_idx) * 100;
    
    fprintf('Test accuracy: %.2f%%\n', testAccuracy);
    
    %% Per-User Accuracy
    fprintf('\n--- Per-User Test Performance ---\n');
    perUserAcc = zeros(numClasses, 1);
    for i = 1:numClasses
        userID = uniqueUsers(i);
        userMask = (y_test_idx == i);
        if sum(userMask) > 0
            perUserAcc(i) = sum(y_test_pred_idx(userMask)' == y_test_idx(userMask)) / sum(userMask) * 100;
            fprintf('User %d: %.2f%% (%d samples)\n', userID, perUserAcc(i), sum(userMask));
        end
    end
    
    %% Package results
    results = struct();
    results.scenario = 3;
    results.modality = modality;
    results.net = net;
    results.mu = mu;
    results.sigma = sigma;
    results.labelMap = labelMap;
    results.uniqueUsers = uniqueUsers;
    results.numClasses = numClasses;
    results.trainAccuracy = trainAccuracy;
    results.testAccuracy = testAccuracy;
    results.perUserAccuracy = perUserAcc;
    
    % Test data for evaluation
    results.X_test_norm = X_test_norm;
    results.y_test = y_test;
    results.y_test_idx = y_test_idx;
    results.y_test_pred_prob = y_test_pred';
    results.y_test_pred_idx = y_test_pred_idx';
    
    fprintf('\n--- Scenario 3 Summary ---\n');
    fprintf('Scenario: Combined Data (Day 1 + Day 2) with 70/30 Split\n');
    fprintf('Modality: %s\n', upper(modality));
    fprintf('Training accuracy: %.2f%%\n', trainAccuracy);
    fprintf('Test accuracy: %.2f%%\n', testAccuracy);
    fprintf('========================================================\n');
end

