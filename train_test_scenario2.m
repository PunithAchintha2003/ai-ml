function results = train_test_scenario2(modality)
%% TRAIN_TEST_SCENARIO2 - Test Scenario 2: Train on Day 1, test on Day 2
% =========================================================================
% This is the MOST REALISTIC scenario where the system is trained on one
% day and tested on a different day. This evaluates how well the system
% handles temporal variations in user behavior (different time, conditions, etc.)
%
% Input:
%   modality: 'accel', 'gyro', or 'combined'
%
% Output:
%   results: struct containing trained model, predictions, and test data
%
% Test Configuration:
%   - Training: ALL Day 1 data
%   - Testing: ALL Day 2 data
%   - No overlap between training and testing sessions
%
% This scenario is most realistic because:
%   - Users don't retrain the system every time they use it
%   - Captures day-to-day behavioral variations
%   - Tests generalization across different sessions
%
% Reference: Experimental setup requirement - Test 2 (Most Realistic)
% =========================================================================

    fprintf('\n========================================================\n');
    fprintf('SCENARIO 2: Train on Day 1, Test on Day 2 (REALISTIC)\n');
    fprintf('Modality: %s\n', upper(modality));
    fprintf('========================================================\n');
    
    %% Load Day 1 features (training)
    switch lower(modality)
        case 'accel'
            load('results/features_day1_accel.mat', 'features_d1_accel', 'labels_d1_accel');
            load('results/features_day2_accel.mat', 'features_d2_accel', 'labels_d2_accel');
            X_train = features_d1_accel;
            y_train = labels_d1_accel;
            X_test = features_d2_accel;
            y_test = labels_d2_accel;
        case 'gyro'
            load('results/features_day1_gyro.mat', 'features_d1_gyro', 'labels_d1_gyro');
            load('results/features_day2_gyro.mat', 'features_d2_gyro', 'labels_d2_gyro');
            X_train = features_d1_gyro;
            y_train = labels_d1_gyro;
            X_test = features_d2_gyro;
            y_test = labels_d2_gyro;
        case 'combined'
            load('results/features_day1_combined.mat', 'features_d1_combined', 'labels_d1_combined');
            load('results/features_day2_combined.mat', 'features_d2_combined', 'labels_d2_combined');
            X_train = features_d1_combined;
            y_train = labels_d1_combined;
            X_test = features_d2_combined;
            y_test = labels_d2_combined;
        otherwise
            error('Invalid modality. Choose: accel, gyro, or combined');
    end
    
    fprintf('Training samples (Day 1): %d\n', size(X_train, 1));
    fprintf('Testing samples (Day 2): %d\n', size(X_test, 1));
    fprintf('Number of features: %d\n', size(X_train, 2));
    fprintf('Number of users: %d\n', length(unique(y_train)));
    
    %% Standardize Features
    fprintf('\nStandardizing features (using Day 1 statistics)...\n');
    
    mu = mean(X_train);
    sigma = std(X_train);
    sigma(sigma == 0) = 1; % Avoid division by zero
    
    X_train_norm = (X_train - mu) ./ sigma;
    X_test_norm = (X_test - mu) ./ sigma;
    
    %% Prepare labels for neural network
    uniqueUsers = unique(y_train);
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
    
    fprintf('Training neural network on Day 1 data...\n');
    
    % Transpose data for MATLAB's neural network format
    X_train_t = X_train_norm';
    y_train_onehot = full(ind2vec(y_train_idx'));
    
    % Train
    [net, tr] = train(net, X_train_t, y_train_onehot);
    
    fprintf('✓ Training complete!\n');
    
    %% Evaluate on Training Data (Day 1)
    y_train_pred = net(X_train_t);
    [~, y_train_pred_idx] = max(y_train_pred);
    trainAccuracy = sum(y_train_pred_idx' == y_train_idx) / length(y_train_idx) * 100;
    
    fprintf('\nDay 1 (Training) accuracy: %.2f%%\n', trainAccuracy);
    
    %% Evaluate on Test Data (Day 2)
    fprintf('Testing on Day 2 data...\n');
    X_test_t = X_test_norm';
    y_test_pred = net(X_test_t);
    [~, y_test_pred_idx] = max(y_test_pred);
    testAccuracy = sum(y_test_pred_idx' == y_test_idx) / length(y_test_idx) * 100;
    
    fprintf('Day 2 (Testing) accuracy: %.2f%%\n', testAccuracy);
    
    % Performance degradation
    degradation = trainAccuracy - testAccuracy;
    fprintf('\nPerformance degradation (Day 1 → Day 2): %.2f%%\n', degradation);
    if degradation > 5
        fprintf('⚠️  Significant behavioral change detected between days!\n');
    else
        fprintf('✓ Behavior is stable across days\n');
    end
    
    %% Per-User Accuracy
    fprintf('\n--- Per-User Test Performance (Day 2) ---\n');
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
    results.scenario = 2;
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
    results.degradation = degradation;
    
    % Test data for evaluation
    results.X_test_norm = X_test_norm;
    results.y_test = y_test;
    results.y_test_idx = y_test_idx;
    results.y_test_pred_prob = y_test_pred';
    results.y_test_pred_idx = y_test_pred_idx';
    
    fprintf('\n--- Scenario 2 Summary ---\n');
    fprintf('Scenario: Train on Day 1, Test on Day 2\n');
    fprintf('Modality: %s\n', upper(modality));
    fprintf('Training accuracy (Day 1): %.2f%%\n', trainAccuracy);
    fprintf('Test accuracy (Day 2): %.2f%%\n', testAccuracy);
    fprintf('Performance degradation: %.2f%%\n', degradation);
    fprintf('========================================================\n');
end

