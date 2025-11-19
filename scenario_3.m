function results = scenario_3(modality, cfg)
%% SCENARIO_3 - Test Scenario 3: Combined data 70/30 split
% =========================================================================
% Combined data scenario
%
% Input:
%   modality: 'accel', 'gyro', or 'combined'
%   cfg: (optional) configuration struct
%
% Output:
%   results: struct containing trained model, predictions, and test data
%
% Test Configuration:
%   - Training: 70% of combined Day 1 + Day 2 data
%   - Testing: 30% of combined data
%   - Stratified split maintains class balance
% =========================================================================

    % Add utils to path
    addpath('utils');

    %% Load configuration
    if nargin < 2 || isempty(cfg)
        cfg = config();
    end
    
    fprintf('\n========================================================\n');
    fprintf('SCENARIO 3: Combined Data 70/30 Split\n');
    fprintf('Modality: %s\n', upper(modality));
    fprintf('========================================================\n');
    
    %% Load and combine features from both days
    [X_day1, y_day1] = load_features(modality, 1);
    [X_day2, y_day2] = load_features(modality, 2);
    
    % Combine datasets
    X = [X_day1; X_day2];
    y = [y_day1; y_day2];
    
    fprintf('Total samples (Day 1 + Day 2): %d\n', size(X, 1));
    fprintf('Number of features: %d\n', size(X, 2));
    fprintf('Number of users: %d\n', length(unique(y)));
    
    %% Stratified Train/Test Split
    fprintf('\nSplitting combined data (%.0f%% train / %.0f%% test)...\n', ...
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
    results = train(X_train, y_train, X_test, y_test, 3, modality, cfg);
    
    fprintf('\n--- Scenario 3 Summary ---\n');
    fprintf('Training accuracy: %.2f%%\n', results.trainAccuracy);
    fprintf('Test accuracy: %.2f%%\n', results.testAccuracy);
    fprintf('Training time: %.2f seconds\n', results.trainTime);
    fprintf('========================================================\n');
end

