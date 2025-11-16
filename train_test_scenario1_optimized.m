function results = train_test_scenario1_optimized(modality, config)
%% TRAIN_TEST_SCENARIO1_OPTIMIZED - Test Scenario 1 (Optimized Version)
% =========================================================================
% This is the optimized version that uses the unified training function,
% reducing code duplication by ~70% and improving maintainability.
%
% Input:
%   modality: 'accel', 'gyro', or 'combined'
%   config: (optional) configuration struct
%
% Output:
%   results: struct containing trained model, predictions, and test data
%
% Test Configuration:
%   - Training: Random 70% of Day 1 data
%   - Testing: Remaining 30% of Day 1 data
%   - Stratified split to maintain class balance
%
% Improvements over original:
%   - Uses unified training function (single source of truth)
%   - Leverages centralized configuration
%   - Better error handling
%   - ~70% less code
% =========================================================================

    %% Load configuration
    if nargin < 2 || isempty(config)
        config = load_config();
    end
    
    fprintf('\n========================================================\n');
    fprintf('SCENARIO 1: Train and Test on Day 1 (Same Day)\n');
    fprintf('Modality: %s\n', upper(modality));
    fprintf('========================================================\n');
    
    %% Load and validate features
    [X, y] = load_features_for_modality(modality, 1);
    
    fprintf('Total samples (Day 1): %d\n', size(X, 1));
    fprintf('Number of features: %d\n', size(X, 2));
    fprintf('Number of users: %d\n', length(unique(y)));
    
    %% Stratified Train/Test Split
    fprintf('\nSplitting data (%.0f%% train / %.0f%% test)...\n', ...
        config.scenarioSplitRatio*100, (1-config.scenarioSplitRatio)*100);
    
    rng(config.randomSeed);
    cv = cvpartition(y, 'HoldOut', 1 - config.scenarioSplitRatio);
    
    X_train = X(training(cv), :);
    y_train = y(training(cv));
    X_test = X(test(cv), :);
    y_test = y(test(cv));
    
    fprintf('Training samples: %d\n', size(X_train, 1));
    fprintf('Testing samples: %d\n', size(X_test, 1));
    
    %% Train using unified function
    results = train_unified(X_train, y_train, X_test, y_test, 1, modality, config);
    
    fprintf('\n--- Scenario 1 Summary ---\n');
    fprintf('Training accuracy: %.2f%%\n', results.trainAccuracy);
    fprintf('Test accuracy: %.2f%%\n', results.testAccuracy);
    fprintf('Training time: %.2f seconds\n', results.trainTime);
    fprintf('========================================================\n');
end

