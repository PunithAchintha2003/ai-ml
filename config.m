function cfg = config()
%% CONFIG - Centralized configuration for all experiments
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
%   cfg: struct containing all configuration parameters
%
% Usage:
%   cfg = config();
%   cfg.epochs = 500;  % Override if needed
% =========================================================================

    cfg = struct();
    
    %% Neural Network Architecture
    cfg.hiddenLayers = [128, 64];           % Hidden layer sizes
    cfg.trainingAlgorithm = 'trainscg';     % Scaled Conjugate Gradient
    % Alternatives: 'trainlm' (Levenberg-Marquardt, faster but more memory)
    %              'traingd' (Gradient Descent, slower)
    %              'trainrp' (Resilient Backpropagation)
    
    %% Training Parameters
    cfg.epochs = 300;                       % Maximum training epochs
    cfg.performFcn = 'crossentropy';        % Loss function
    cfg.showWindow = false;                 % Show training GUI
    cfg.showCommandLine = false;            % Show training progress
    
    %% Data Splitting
    cfg.trainRatio = 0.85;                  % Training set ratio
    cfg.valRatio = 0.15;                    % Validation set ratio
    cfg.testRatio = 0.0;                    % Test set (handled separately)
    cfg.scenarioSplitRatio = 0.70;          % Train/test split for scenarios 1 & 3
    
    %% Feature Extraction
    cfg.windowSize = 4.0;                   % Window size in seconds
    cfg.overlap = 0.5;                      % 50% overlap
    cfg.samplingRate = 30;                  % Hz
    
    %% Performance Optimization
    cfg.useGPU = false;                     % Enable GPU acceleration (if available)
    cfg.useParallel = false;                % Use parallel processing for experiments (set true if you have Parallel Computing Toolbox)
    cfg.numWorkers = 4;                     % Number of parallel workers (auto-detect if 0)
    
    %% Evaluation Settings
    cfg.numThresholds = 1000;               % For FAR/FRR computation
    cfg.randomSeed = 42;                    % For reproducibility
    
    %% Visualization
    cfg.saveFigures = true;                 % Auto-save generated figures
    cfg.figureFormat = 'png';               % Figure format: png, pdf, eps
    cfg.figureResolution = 300;             % DPI for saved figures
    
    %% File Paths
    cfg.dataPath = 'Dataset/';
    cfg.resultsPath = 'results/';
    cfg.figuresPath = 'results/';
    
    %% Advanced Settings
    cfg.enableEarlyStopping = true;         % Stop if validation error increases
    cfg.maxFailIterations = 6;              % Max validation failures before stopping
    cfg.minGradient = 1e-7;                 % Minimum gradient for stopping
    cfg.maxTrainTime = inf;                 % Maximum training time (seconds)
    
    %% Feature Selection (for optimize_model.m)
    cfg.featureSelectionMethods = {'fscmrmr', 'relieff', 'anova'};
    cfg.featureCounts = [5, 10, 15, 20, 30, 51];
    cfg.cvFolds = 4;                        % Cross-validation folds
    
    %% Hyperparameter Search Space (for future optimization)
    cfg.hiddenLayerOptions = {[64, 32], [128, 64], [256, 128], [128], [256]};
    cfg.learningRateRange = [0.001, 0.1];
    cfg.regularizationRange = [0, 0.1];
    
    %% Display current configuration
    fprintf('\n--- Configuration Loaded ---\n');
    fprintf('Architecture: %s\n', mat2str(cfg.hiddenLayers));
    fprintf('Training Algorithm: %s\n', cfg.trainingAlgorithm);
    fprintf('Epochs: %d\n', cfg.epochs);
    fprintf('Window Size: %.1f seconds\n', cfg.windowSize);
    fprintf('GPU Acceleration: %s\n', boolToStr(cfg.useGPU));
    fprintf('Parallel Processing: %s\n', boolToStr(cfg.useParallel));
    fprintf('Random Seed: %d\n', cfg.randomSeed);
    fprintf('----------------------------\n');
    
    % Set random seed for reproducibility
    rng(cfg.randomSeed);
end

function str = boolToStr(val)
    if val
        str = 'Enabled';
    else
        str = 'Disabled';
    end
end

