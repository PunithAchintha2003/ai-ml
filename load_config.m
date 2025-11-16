function config = load_config()
%% LOAD_CONFIG - Centralized configuration for all experiments
% =========================================================================
% This function provides a single source of truth for all hyperparameters
% and configuration settings used throughout the project.
%
% Benefits:
%   - Easy to modify parameters in one place
%   - Consistent settings across all experiments
%   - Better documentation of choices
%   - Facilitates hyperparameter tuning
%
% Output:
%   config: struct containing all configuration parameters
%
% Usage:
%   config = load_config();
%   config.epochs = 500;  % Override if needed
% =========================================================================

    config = struct();
    
    %% Neural Network Architecture
    config.hiddenLayers = [128, 64];           % Hidden layer sizes
    config.trainingAlgorithm = 'trainscg';     % Scaled Conjugate Gradient
    % Alternatives: 'trainlm' (Levenberg-Marquardt, faster but more memory)
    %              'traingd' (Gradient Descent, slower)
    %              'trainrp' (Resilient Backpropagation)
    
    %% Training Parameters
    config.epochs = 300;                       % Maximum training epochs
    config.performFcn = 'crossentropy';        % Loss function
    config.showWindow = false;                 % Show training GUI
    config.showCommandLine = false;            % Show training progress
    
    %% Data Splitting
    config.trainRatio = 0.85;                  % Training set ratio
    config.valRatio = 0.15;                    % Validation set ratio
    config.testRatio = 0.0;                    % Test set (handled separately)
    config.scenarioSplitRatio = 0.70;          % Train/test split for scenarios 1 & 3
    
    %% Feature Extraction
    config.windowSize = 4.0;                   % Window size in seconds
    config.overlap = 0.5;                      % 50% overlap
    config.samplingRate = 30;                  % Hz
    
    %% Performance Optimization
    config.useGPU = false;                     % Enable GPU acceleration (if available)
    config.useParallel = false;                % Use parallel processing for experiments (set true if you have Parallel Computing Toolbox)
    config.numWorkers = 4;                     % Number of parallel workers (auto-detect if 0)
    
    %% Evaluation Settings
    config.numThresholds = 1000;               % For FAR/FRR computation
    config.randomSeed = 42;                    % For reproducibility
    
    %% Visualization
    config.saveFigures = true;                 % Auto-save generated figures
    config.figureFormat = 'png';               % Figure format: png, pdf, eps
    config.figureResolution = 300;             % DPI for saved figures
    
    %% File Paths
    config.dataPath = 'Dataset/';
    config.resultsPath = 'results/';
    config.figuresPath = 'results/';
    
    %% Advanced Settings
    config.enableEarlyStopping = true;         % Stop if validation error increases
    config.maxFailIterations = 6;              % Max validation failures before stopping
    config.minGradient = 1e-7;                 % Minimum gradient for stopping
    config.maxTrainTime = inf;                 % Maximum training time (seconds)
    
    %% Feature Selection (for optimize_model.m)
    config.featureSelectionMethods = {'fscmrmr', 'relieff', 'anova'};
    config.featureCounts = [5, 10, 15, 20, 30, 51];
    config.cvFolds = 4;                        % Cross-validation folds
    
    %% Hyperparameter Search Space (for future optimization)
    config.hiddenLayerOptions = {[64, 32], [128, 64], [256, 128], [128], [256]};
    config.learningRateRange = [0.001, 0.1];
    config.regularizationRange = [0, 0.1];
    
    %% Display current configuration
    fprintf('\n--- Configuration Loaded ---\n');
    fprintf('Architecture: %s\n', mat2str(config.hiddenLayers));
    fprintf('Training Algorithm: %s\n', config.trainingAlgorithm);
    fprintf('Epochs: %d\n', config.epochs);
    fprintf('Window Size: %.1f seconds\n', config.windowSize);
    fprintf('GPU Acceleration: %s\n', boolToStr(config.useGPU));
    fprintf('Parallel Processing: %s\n', boolToStr(config.useParallel));
    fprintf('Random Seed: %d\n', config.randomSeed);
    fprintf('----------------------------\n');
    
    % Set random seed for reproducibility
    rng(config.randomSeed);
end

function str = boolToStr(val)
    if val
        str = 'Enabled';
    else
        str = 'Disabled';
    end
end

