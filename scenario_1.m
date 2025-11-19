function results = scenario_1(modality, cfg)
%% SCENARIO_1 - Test Scenario 1: Train and test on Day 1
% =========================================================================
% This is unified training function
%
% Input:
%   modality: 'accel', 'gyro', or 'combined'
%   cfg: (optional) configuration struct
%
% Output:
%   results: struct containing trained model, predictions, and test data
%
% Test Configuration:
%   - Training: Random 70% of Day 1 data
%   - Testing: Remaining 30% of Day 1 data
%   - Stratified split to maintain class balance
% =========================================================================

    % Add utils to path
    addpath('utils');

    %% Load configuration
    if nargin < 2 || isempty(cfg)
        cfg = config();
    end
    
    fprintf('\n========================================================\n');
    fprintf('SCENARIO 1: Train and Test on Day 1 (Same Day)\n');
    fprintf('Modality: %s\n', upper(modality));
    fprintf('========================================================\n');
    
    %% Load and validate features
    [X, y] = load_features(modality, 1);
    
    fprintf('Total samples (Day 1): %d\n', size(X, 1));
    fprintf('Number of features: %d\n', size(X, 2));
    fprintf('Number of users: %d\n', length(unique(y)));
    
    %% Stratified Train/Test Split
    fprintf('\nSplitting data (%.0f%% train / %.0f%% test)...\n', ...
        cfg.scenarioSplitRatio*100, (1-cfg.scenarioSplitRatio)*100);
    
    rng(cfg.randomSeed);
    cv = cvpartition(y, 'HoldOut', 1 - cfg.scenarioSplitRatio);
    
    X_train = X(training(cv), :);
    y_train = y(training(cv));
    X_test = X(test(cv), :);
    y_test = y(test(cv));
    
    fprintf('Training samples: %d\n', size(X_train, 1));
    fprintf('Testing samples: %d\n', size(X_test, 1));
    
    %% Train using unified function
    results = train(X_train, y_train, X_test, y_test, 1, modality, cfg);
    
    fprintf('\n--- Scenario 1 Summary ---\n');
    fprintf('Training accuracy: %.2f%%\n', results.trainAccuracy);
    fprintf('Test accuracy: %.2f%%\n', results.testAccuracy);
    fprintf('Training time: %.2f seconds\n', results.trainTime);
    fprintf('========================================================\n');
end

