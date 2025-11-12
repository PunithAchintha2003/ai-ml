function train_nn()
%% TRAIN_NN - Train baseline neural network for user authentication
% =========================================================================
% This function builds and trains a multi-layer perceptron (MLP) neural
% network for classifying user identity based on accelerometer features.
%
% Architecture:
%   - Input layer: number of features
%   - Hidden layer 1: 128 neurons (ReLU activation)
%   - Hidden layer 2: 64 neurons (ReLU activation)
%   - Output layer: number of users (Softmax)
%
% Training Configuration:
%   - Loss function: Cross-entropy
%   - Training/Testing split: 75% / 25% (stratified)
%   - Epochs: 300
%   - Validation: 15% of training data
%
% Output:
%   - results/baseline_model.mat containing trained network and metadata
%
% Reference: [3] Goodfellow et al., 2016 - Deep Learning (MIT Press)
% =========================================================================

    fprintf('Loading feature data...\n');
    load('results/featuresTable.mat', 'allFeatures', 'allLabels');
    
    % Data summary
    fprintf('Dataset size: %d samples x %d features\n', size(allFeatures));
    fprintf('Number of users: %d\n', length(unique(allLabels)));
    
    %% Stratified Train/Test Split (75/25)
    fprintf('\nSplitting data (75%% train / 25%% test)...\n');
    
    rng(42); % For reproducibility
    cv = cvpartition(allLabels, 'HoldOut', 0.25);
    
    trainIdx = training(cv);
    testIdx = test(cv);
    
    X_train = allFeatures(trainIdx, :);
    y_train = allLabels(trainIdx);
    X_test = allFeatures(testIdx, :);
    y_test = allLabels(testIdx);
    
    fprintf('Training samples: %d\n', size(X_train, 1));
    fprintf('Testing samples: %d\n', size(X_test, 1));
    
    %% Standardize Features (Z-score normalization)
    fprintf('\nStandardizing features...\n');
    
    % Compute statistics from training data only
    mu = mean(X_train);
    sigma = std(X_train);
    sigma(sigma == 0) = 1; % Avoid division by zero
    
    % Apply to both train and test
    X_train_norm = (X_train - mu) ./ sigma;
    X_test_norm = (X_test - mu) ./ sigma;
    
    %% Prepare labels for neural network
    % Convert labels to categorical format
    uniqueUsers = unique(allLabels);
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
    
    y_train_cat = categorical(y_train_idx);
    y_test_cat = categorical(y_test_idx);
    
    %% Build Neural Network Architecture
    fprintf('\nBuilding neural network architecture...\n');
    fprintf('  Input layer: %d neurons\n', size(X_train_norm, 2));
    fprintf('  Hidden layer 1: 128 neurons (ReLU)\n');
    fprintf('  Hidden layer 2: 64 neurons (ReLU)\n');
    fprintf('  Output layer: %d neurons (Softmax)\n', numClasses);
    
    % Create pattern recognition network
    hiddenLayerSize = [128, 64];
    net = patternnet(hiddenLayerSize, 'trainscg');
    
    % Configure training
    net.trainParam.epochs = 300;
    net.trainParam.showWindow = false;
    net.trainParam.showCommandLine = false;
    net.divideParam.trainRatio = 0.85; % 85% of training data for training
    net.divideParam.valRatio = 0.15;   % 15% for validation
    net.divideParam.testRatio = 0;     % We have separate test set
    
    % Use cross-entropy performance function
    net.performFcn = 'crossentropy';
    
    %% Train the Network
    fprintf('\nTraining neural network...\n');
    fprintf('This may take a few minutes...\n');
    
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
    
    %% Save Model and Metadata
    fprintf('\nSaving trained model...\n');
    
    % Prepare model package
    model = struct();
    model.net = net;
    model.mu = mu;
    model.sigma = sigma;
    model.labelMap = labelMap;
    model.uniqueUsers = uniqueUsers;
    model.numClasses = numClasses;
    model.hiddenLayerSize = hiddenLayerSize;
    model.trainAccuracy = trainAccuracy;
    model.testAccuracy = testAccuracy;
    
    % Save train/test indices for evaluation
    model.trainIdx = trainIdx;
    model.testIdx = testIdx;
    model.X_test_norm = X_test_norm;
    model.y_test = y_test;
    model.y_test_idx = y_test_idx;
    
    save('results/baseline_model.mat', 'model', '-v7.3');
    
    fprintf('\n--- Training Summary ---\n');
    fprintf('Architecture: [%d] -> [%s] -> [%d]\n', ...
        size(X_train_norm, 2), ...
        strjoin(arrayfun(@num2str, hiddenLayerSize, 'UniformOutput', false), ', '), ...
        numClasses);
    fprintf('Training accuracy: %.2f%%\n', trainAccuracy);
    fprintf('Test accuracy: %.2f%%\n', testAccuracy);
    fprintf('Model saved to results/baseline_model.mat\n');
end

