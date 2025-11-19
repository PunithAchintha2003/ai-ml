function results = scenario_2(modality, cfg)
%% SCENARIO_2 - Test Scenario 2: Train Day 1, Test Day 2 (Realistic)
% =========================================================================
% Train on Day 1, test on Day 2.
%
% Input:
%   modality: 'accel', 'gyro', or 'combined'
%   cfg: (optional) configuration struct
%
% Output:
%   results: struct containing trained model, predictions, and test data
%
% Test Configuration:
%   - Training: ALL Day 1 data
%   - Testing: ALL Day 2 data
%   - No overlap between training and testing sessions
% =========================================================================

    % Add utils to path
    addpath('utils');

    %% Load configuration
    if nargin < 2 || isempty(cfg)
        cfg = config();
    end
    
    fprintf('\n========================================================\n');
    fprintf('SCENARIO 2: Train on Day 1, Test on Day 2\n');
    fprintf('Modality: %s\n', upper(modality));
    fprintf('========================================================\n');
    
    %% Load features for both days
    [X_train, y_train] = load_features(modality, 1);
    [X_test, y_test] = load_features(modality, 2);
    
    fprintf('Training samples (Day 1): %d\n', size(X_train, 1));
    fprintf('Testing samples (Day 2): %d\n', size(X_test, 1));
    fprintf('Number of features: %d\n', size(X_train, 2));
    fprintf('Number of users: %d\n', length(unique(y_train)));
    
    %% Train using unified function
    results = train(X_train, y_train, X_test, y_test, 2, modality, cfg);
    
    fprintf('\n--- Scenario 2 Summary ---\n');
    fprintf('Training accuracy (Day 1): %.2f%%\n', results.trainAccuracy);
    fprintf('Test accuracy (Day 2): %.2f%%\n', results.testAccuracy);
    fprintf('Performance degradation: %.2f%%\n', results.degradation);
    fprintf('Training time: %.2f seconds\n', results.trainTime);
    fprintf('========================================================\n');
end

