%% UTILS_BIOMETRIC - Utility functions for biometric authentication project
% =========================================================================
% This file contains common utility functions used throughout the project.
%
% Benefits:
%   - Eliminates code duplication
%   - Provides consistent functionality
%   - Easier to test and maintain
%   - Better code organization
%
% Functions:
%   - load_features_for_modality: Load features for a specific modality and day
%   - validate_modality: Validate modality string
%   - create_results_dir: Ensure results directory exists
%   - format_time: Format elapsed time in human-readable format
%   - compute_class_weights: Compute class weights for imbalanced datasets
%   - standardize_features: Standardize features with safety checks
% =========================================================================

function [X, y] = load_features_for_modality(modality, day)
    %% LOAD_FEATURES_FOR_MODALITY - Load feature matrix for given modality and day
    % Input:
    %   modality: 'accel', 'gyro', or 'combined'
    %   day: 1 or 2
    % Output:
    %   X: Feature matrix
    %   y: Labels
    
    % Validate inputs
    validate_modality(modality);
    if ~ismember(day, [1, 2])
        error('Day must be 1 or 2');
    end
    
    % Construct filename
    dayStr = sprintf('day%d', day);
    filename = sprintf('results/features_%s_%s.mat', dayStr, lower(modality));
    
    % Check if file exists
    if ~exist(filename, 'file')
        error('Feature file not found: %s\nPlease run extract_features() first.', filename);
    end
    
    % Load based on modality and day
    switch lower(modality)
        case 'accel'
            varName = sprintf('features_%s_accel', dayStr(1:2));
            labelName = sprintf('labels_%s_accel', dayStr(1:2));
            data = load(filename, varName, labelName);
            X = data.(varName);
            y = data.(labelName);
        case 'gyro'
            varName = sprintf('features_%s_gyro', dayStr(1:2));
            labelName = sprintf('labels_%s_gyro', dayStr(1:2));
            data = load(filename, varName, labelName);
            X = data.(varName);
            y = data.(labelName);
        case 'combined'
            varName = sprintf('features_%s_combined', dayStr(1:2));
            labelName = sprintf('labels_%s_combined', dayStr(1:2));
            data = load(filename, varName, labelName);
            X = data.(varName);
            y = data.(labelName);
    end
    
    % Validate loaded data
    if isempty(X) || isempty(y)
        error('Loaded features or labels are empty');
    end
    
    if size(X, 1) ~= length(y)
        error('Feature matrix and label vector have mismatched dimensions');
    end
end

function validate_modality(modality)
    %% VALIDATE_MODALITY - Validate modality string
    % Input:
    %   modality: string to validate
    % Throws error if invalid
    
    validModalities = {'accel', 'gyro', 'combined'};
    if ~ismember(lower(modality), validModalities)
        error('Invalid modality: %s. Choose from: %s', ...
            modality, strjoin(validModalities, ', '));
    end
end

function create_results_dir(config)
    %% CREATE_RESULTS_DIR - Ensure results directory exists
    % Input:
    %   config: (optional) configuration struct with resultsPath
    
    if nargin < 1
        config = load_config();
    end
    
    if ~exist(config.resultsPath, 'dir')
        mkdir(config.resultsPath);
        fprintf('Created directory: %s\n', config.resultsPath);
    end
    
    if ~exist(config.figuresPath, 'dir')
        mkdir(config.figuresPath);
        fprintf('Created directory: %s\n', config.figuresPath);
    end
end

function timeStr = format_time(seconds)
    %% FORMAT_TIME - Format elapsed time in human-readable format
    % Input:
    %   seconds: elapsed time in seconds
    % Output:
    %   timeStr: formatted string (e.g., "2h 15m 30s")
    
    if seconds < 60
        timeStr = sprintf('%.1f seconds', seconds);
    elseif seconds < 3600
        minutes = floor(seconds / 60);
        secs = mod(seconds, 60);
        timeStr = sprintf('%dm %.1fs', minutes, secs);
    else
        hours = floor(seconds / 3600);
        minutes = floor(mod(seconds, 3600) / 60);
        secs = mod(seconds, 60);
        timeStr = sprintf('%dh %dm %.1fs', hours, minutes, secs);
    end
end

function weights = compute_class_weights(labels)
    %% COMPUTE_CLASS_WEIGHTS - Compute class weights for imbalanced datasets
    % Input:
    %   labels: array of class labels
    % Output:
    %   weights: array of weights (same size as labels)
    
    uniqueClasses = unique(labels);
    classCount = histcounts(labels, [uniqueClasses; max(uniqueClasses)+1]);
    
    % Inverse frequency weighting
    totalSamples = length(labels);
    classWeights = totalSamples ./ (length(uniqueClasses) * classCount);
    
    % Map to individual samples
    weights = zeros(size(labels));
    for i = 1:length(uniqueClasses)
        weights(labels == uniqueClasses(i)) = classWeights(i);
    end
end

function [X_norm, mu, sigma] = standardize_features(X)
    %% STANDARDIZE_FEATURES - Standardize features with safety checks
    % Input:
    %   X: feature matrix (samples × features)
    % Output:
    %   X_norm: normalized feature matrix
    %   mu: mean of each feature
    %   sigma: standard deviation of each feature
    
    mu = mean(X, 1);
    sigma = std(X, 0, 1);
    
    % Avoid division by zero
    sigma(sigma == 0) = 1;
    
    % Check for NaN or Inf
    if any(isnan(mu(:))) || any(isinf(mu(:)))
        error('Feature matrix contains NaN or Inf values in means');
    end
    
    X_norm = (X - mu) ./ sigma;
    
    % Verify normalization
    if any(isnan(X_norm(:))) || any(isinf(X_norm(:)))
        error('Normalization produced NaN or Inf values');
    end
end

function [precision, recall, f1] = compute_metrics(y_true, y_pred)
    %% COMPUTE_METRICS - Compute precision, recall, and F1 score
    % Input:
    %   y_true: true labels
    %   y_pred: predicted labels
    % Output:
    %   precision: precision score
    %   recall: recall score
    %   f1: F1 score
    
    % Compute confusion matrix
    C = confusionmat(y_true, y_pred);
    
    numClasses = size(C, 1);
    precision = zeros(numClasses, 1);
    recall = zeros(numClasses, 1);
    
    for i = 1:numClasses
        TP = C(i, i);
        FP = sum(C(:, i)) - TP;
        FN = sum(C(i, :)) - TP;
        
        if (TP + FP) > 0
            precision(i) = TP / (TP + FP);
        end
        
        if (TP + FN) > 0
            recall(i) = TP / (TP + FN);
        end
    end
    
    % Compute F1 score
    f1 = zeros(numClasses, 1);
    for i = 1:numClasses
        if (precision(i) + recall(i)) > 0
            f1(i) = 2 * (precision(i) * recall(i)) / (precision(i) + recall(i));
        end
    end
    
    % Return macro-averaged scores
    precision = mean(precision);
    recall = mean(recall);
    f1 = mean(f1);
end

function save_model(model, filename, config)
    %% SAVE_MODEL - Save model with metadata
    % Input:
    %   model: model struct
    %   filename: output filename
    %   config: (optional) configuration struct
    
    if nargin < 3
        config = load_config();
    end
    
    % Add metadata
    model.timestamp = datetime('now');
    model.matlabVersion = version;
    
    % Save
    fullPath = fullfile(config.resultsPath, filename);
    save(fullPath, 'model');
    fprintf('Model saved to: %s\n', fullPath);
end

function check_dependencies()
    %% CHECK_DEPENDENCIES - Verify required toolboxes are installed
    
    fprintf('Checking MATLAB toolbox dependencies...\n');
    
    required = {
        'Deep Learning Toolbox', 'nnet_cnn';
        'Statistics and Machine Learning Toolbox', 'stats';
        'Signal Processing Toolbox', 'signal'
    };
    
    allPresent = true;
    for i = 1:size(required, 1)
        toolboxName = required{i, 1};
        toolboxShort = required{i, 2};
        
        if license('test', toolboxShort)
            fprintf('  ✓ %s\n', toolboxName);
        else
            fprintf('  ✗ %s (MISSING)\n', toolboxName);
            allPresent = false;
        end
    end
    
    if ~allPresent
        error('Required toolboxes are missing. Please install them to continue.');
    end
    
    fprintf('All dependencies satisfied!\n\n');
end

