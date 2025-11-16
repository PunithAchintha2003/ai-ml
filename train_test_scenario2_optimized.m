function results = train_test_scenario2_optimized(modality, config)
%% TRAIN_TEST_SCENARIO2_OPTIMIZED - Test Scenario 2 (Optimized Version)
% =========================================================================
% MOST REALISTIC scenario - train on Day 1, test on Day 2.
% Optimized version using unified training function.
%
% Input:
%   modality: 'accel', 'gyro', or 'combined'
%   config: (optional) configuration struct
%
% Output:
%   results: struct containing trained model, predictions, and test data
%
% Test Configuration:
%   - Training: ALL Day 1 data
%   - Testing: ALL Day 2 data
%   - No overlap between training and testing sessions
%
% Improvements over original:
%   - Uses unified training function
%   - Better performance tracking
%   - ~70% less code
% =========================================================================

    %% Load configuration
    if nargin < 2 || isempty(config)
        config = load_config();
    end
    
    fprintf('\n========================================================\n');
    fprintf('SCENARIO 2: Train on Day 1, Test on Day 2 (REALISTIC)\n');
    fprintf('Modality: %s\n', upper(modality));
    fprintf('========================================================\n');
    
    %% Load features for both days
    [X_train, y_train] = load_features_for_modality(modality, 1);
    [X_test, y_test] = load_features_for_modality(modality, 2);
    
    fprintf('Training samples (Day 1): %d\n', size(X_train, 1));
    fprintf('Testing samples (Day 2): %d\n', size(X_test, 1));
    fprintf('Number of features: %d\n', size(X_train, 2));
    fprintf('Number of users: %d\n', length(unique(y_train)));
    
    %% Train using unified function
    results = train_unified(X_train, y_train, X_test, y_test, 2, modality, config);
    
    fprintf('\n--- Scenario 2 Summary ---\n');
    fprintf('Training accuracy (Day 1): %.2f%%\n', results.trainAccuracy);
    fprintf('Test accuracy (Day 2): %.2f%%\n', results.testAccuracy);
    fprintf('Performance degradation: %.2f%%\n', results.degradation);
    fprintf('Training time: %.2f seconds\n', results.trainTime);
    fprintf('========================================================\n');
end

