
% Project: Behavioral Biometrics User Authentication
%
% Output:
%   - Results for all 9 combinations (3 scenarios * 3 modalities)
%   - Comparative performance tables
%   - Saved results in results/ folder
%
% Total Experiments: 3 scenarios * 3 modalities = 9 experiments
% =========================================================================

clear all; close all; clc;

% Add utils folder to path
addpath('utils');

fprintf('====================================================\n');
fprintf('BEHAVIORAL BIOMETRICS SETUP\n');
fprintf('====================================================\n');

%% Load configuration
cfg = config();
create_dir(cfg);

% Check dependencies
check_deps();

% Start timer
tic;

%% STEP 1: Preprocess Data
fprintf('\nSTEP 1 Preprocessing sensor data\n');
fprintf('------------------------------------------------------------\n');
if ~exist('results/preprocessed.mat', 'file')
    preprocess();
    fprintf('✓ Preprocessing complete\n');
else
    fprintf('✓ Using existing preprocessed data\n');
end

%% STEP 2: Extract Features
fprintf('\nSTEP 2 Extracting features for all modalities\n');
fprintf('------------------------------------------------------------\n');
featuresExist = exist('results/features_day1_accel.mat', 'file') && ...
                exist('results/features_day1_gyro.mat', 'file') && ...
                exist('results/features_day1_combined.mat', 'file');

if ~featuresExist
        extract_features();
    fprintf('✓ Feature extraction complete\n');
else
    fprintf('✓ Using existing feature files\n');
end

%% STEP 3: Run All Scenarios and Modalities
fprintf('\nSTEP 3 Running experiments (3 scenarios * 3 modalities)...\n');
fprintf('------------------------------------------------------------\n');

scenarios = 1:3;
scenarioNames = {'Test 1: Day 1 Train+Test', ...
                 'Test 2: Day 1 Train, Day 2 Test', ...
                 'Test 3: Combined 70/30'};
modalities = {'accel', 'gyro', 'combined'};
modalityNames = {'Accelerometer Only', 'Gyroscope Only', 'Combined Sensors'};

% Initialize result storage
allResults = cell(length(scenarios), length(modalities));
allEvaluations = cell(length(scenarios), length(modalities));

totalExperiments = length(scenarios) * length(modalities);

%% Run experiments (with optional parallel processing)
if cfg.useParallel
    % Check if Parallel Computing Toolbox is available
    if license('test', 'distrib_computing_toolbox')
        fprintf('Using parallel processing (this may take a moment to initialize)...\n');
        
        % Initialize parallel pool if not already running
        try
            pool = gcp('nocreate');
            if isempty(pool)
                numWorkers = cfg.numWorkers;
                if numWorkers == 0
                    numWorkers = feature('numcores');
                end
                try
                    parpool('local', numWorkers);
                    fprintf('✓ Parallel pool initialized with %d workers\n', numWorkers);
                catch ME
                    fprintf('⚠ Could not initialize parallel pool: %s\n', ME.message);
                    fprintf('⚠ Using sequential execution instead\n');
                    cfg.useParallel = false;
                end
            else
                fprintf('✓ Using existing parallel pool with %d workers\n', pool.NumWorkers);
            end
        catch ME
            fprintf('⚠ Parallel processing error: %s\n', ME.message);
            fprintf('⚠ Using sequential execution instead\n');
            cfg.useParallel = false;
        end
    else
        fprintf('⚠ Parallel Computing Toolbox not available\n');
        fprintf('⚠ Using sequential execution instead\n');
        cfg.useParallel = false;
    end
end

if ~cfg.useParallel
    fprintf('Using sequential processing (no parallelization)...\n');
end

experimentCount = 0;

% Run experiments
for s = 1:length(scenarios)
    for m = 1:length(modalities)
        experimentCount = experimentCount + 1;
        
        fprintf('\n════════════════════════════════════════════════════════\n');
        fprintf('EXPERIMENT %d/%d\n', experimentCount, totalExperiments);
        fprintf('Scenario: %s\n', scenarioNames{s});
        fprintf('Modality: %s\n', modalityNames{m});
        fprintf('════════════════════════════════════════════════════════\n');
        
        try
            % Run scenario using optimized functions
            switch scenarios(s)
                case 1
                    model = scenario_1(modalities{m}, cfg);
                case 2
                    model = scenario_2(modalities{m}, cfg);
                case 3
                    model = scenario_3(modalities{m}, cfg);
            end
            
            % Evaluate model
            evaluation = evaluate(model);
            
            % Store results
            allResults{s, m} = model;
            allEvaluations{s, m} = evaluation;
            
            % Save individual result
            save(sprintf('results/model_scenario%d_%s_optimized.mat', ...
                scenarios(s), modalities{m}), 'model', 'evaluation');
            
            fprintf('\n✓ Experiment %d/%d complete\n', experimentCount, totalExperiments);
            
        catch ME
            fprintf('\n✗ Experiment %d/%d FAILED: %s\n', experimentCount, totalExperiments, ME.message);
            fprintf('  Stack trace:\n');
            for k = 1:length(ME.stack)
                fprintf('    %s (line %d)\n', ME.stack(k).name, ME.stack(k).line);
            end
            % Store empty results to maintain indexing
            allResults{s, m} = struct('error', ME.message);
            allEvaluations{s, m} = struct('error', ME.message);
        end
    end
end

fprintf('\n✓ All experiments completed!\n');

%% STEP 4: Generate Comparison Tables
fprintf('\nSTEP 4 Generating comparison tables...\n');
fprintf('------------------------------------------------------------\n');

% Create comprehensive comparison table
comparisonTable = cell(totalExperiments + 1, 8);
comparisonTable(1, :) = {'Scenario', 'Modality', 'Train Acc (%)', 'Test Acc (%)', ...
                         'EER (%)', 'Avg FAR (%)', 'Avg FRR (%)', 'Train Time (s)'};

row = 2;
for s = 1:length(scenarios)
    for m = 1:length(modalities)
        model = allResults{s, m};
        eval = allEvaluations{s, m};
        
        if ~isfield(model, 'error') && ~isfield(eval, 'error')
            comparisonTable{row, 1} = scenarioNames{s};
            comparisonTable{row, 2} = modalityNames{m};
            comparisonTable{row, 3} = sprintf('%.2f', model.trainAccuracy);
            comparisonTable{row, 4} = sprintf('%.2f', model.testAccuracy);
            comparisonTable{row, 5} = sprintf('%.2f', eval.EER);
            comparisonTable{row, 6} = sprintf('%.2f', mean(eval.perUserFAR));
            comparisonTable{row, 7} = sprintf('%.2f', mean(eval.perUserFRR));
            comparisonTable{row, 8} = sprintf('%.2f', model.trainTime);
        else
            comparisonTable{row, 1} = scenarioNames{s};
            comparisonTable{row, 2} = modalityNames{m};
            comparisonTable{row, 3} = 'ERROR';
            comparisonTable{row, 4} = 'ERROR';
            comparisonTable{row, 5} = 'ERROR';
            comparisonTable{row, 6} = 'ERROR';
            comparisonTable{row, 7} = 'ERROR';
            comparisonTable{row, 8} = 'ERROR';
        end
        
        row = row + 1;
    end
end

% Display comparison table
fprintf('\n════════════════════════════════════════════════════════════════════════════════════════\n');
fprintf('COMPREHENSIVE RESULTS COMPARISON (All Scenarios * All Modalities)\n');
fprintf('═══════════════════════════════════════════════════════════════════════════════════════════\n');
fprintf('%-40s | %-20s | %10s | %10s | %8s | %9s | %9s | %12s\n', ...
    'Scenario', 'Modality', 'Train Acc', 'Test Acc', 'EER', 'Avg FAR', 'Avg FRR', 'Train Time');
fprintf('───────────────────────────────────────────────────────────────────────────────────────────\n');

for i = 2:size(comparisonTable, 1)
    fprintf('%-40s | %-20s | %10s | %10s | %8s | %9s | %9s | %12s\n', ...
        comparisonTable{i, 1}, comparisonTable{i, 2}, comparisonTable{i, 3}, ...
        comparisonTable{i, 4}, comparisonTable{i, 5}, comparisonTable{i, 6}, ...
        comparisonTable{i, 7}, comparisonTable{i, 8});
end

fprintf('═══════════════════════════════════════════════════════════════════════════════════════════\n\n');

%% Analysis by Scenario
fprintf('\n--- Analysis by Scenario ---\n');
for s = 1:length(scenarios)
    fprintf('\n%s:\n', scenarioNames{s});
    for m = 1:length(modalities)
        eval = allEvaluations{s, m};
        if ~isfield(eval, 'error')
            fprintf('  %s: Acc=%.2f%%, EER=%.2f%%\n', ...
                modalityNames{m}, eval.accuracy, eval.EER);
        else
            fprintf('  %s: ERROR\n', modalityNames{m});
        end
    end
end

%% Analysis by Modality
fprintf('\n--- Analysis by Modality ---\n');
for m = 1:length(modalities)
    fprintf('\n%s:\n', modalityNames{m});
    for s = 1:length(scenarios)
        eval = allEvaluations{s, m};
        if ~isfield(eval, 'error')
            fprintf('  %s: Acc=%.2f%%, EER=%.2f%%\n', ...
                scenarioNames{s}, eval.accuracy, eval.EER);
        else
            fprintf('  %s: ERROR\n', scenarioNames{s});
        end
    end
end

%% Find Best Configurations
fprintf('\n--- Best Performing Configurations ---\n');

% Find best overall accuracy
bestAccuracy = 0;
bestAccName = '';
for s = 1:length(scenarios)
    for m = 1:length(modalities)
        eval = allEvaluations{s, m};
        if ~isfield(eval, 'error') && eval.accuracy > bestAccuracy
            bestAccuracy = eval.accuracy;
            bestAccName = sprintf('%s + %s', scenarioNames{s}, modalityNames{m});
        end
    end
end
fprintf('Best Accuracy: %.2f%% (%s)\n', bestAccuracy, bestAccName);

% Find best (lowest) EER
bestEER = 100;
bestEERName = '';
for s = 1:length(scenarios)
    for m = 1:length(modalities)
        eval = allEvaluations{s, m};
        if ~isfield(eval, 'error') && eval.EER < bestEER
            bestEER = eval.EER;
            bestEERName = sprintf('%s + %s', scenarioNames{s}, modalityNames{m});
        end
    end
end
fprintf('Best EER: %.2f%% (%s)\n', bestEER, bestEERName);

% Find fastest training
fastestTime = inf;
fastestName = '';
for s = 1:length(scenarios)
    for m = 1:length(modalities)
        model = allResults{s, m};
        if ~isfield(model, 'error') && model.trainTime < fastestTime
            fastestTime = model.trainTime;
            fastestName = sprintf('%s + %s', scenarioNames{s}, modalityNames{m});
        end
    end
end
fprintf('Fastest Training: %.2f seconds (%s)\n', fastestTime, fastestName);

% Most realistic scenario performance
fprintf('\n--- Most Realistic Scenario (Test 2: Day 1→Day 2) ---\n');
for m = 1:length(modalities)
    eval = allEvaluations{2, m};
    model = allResults{2, m};
    if ~isfield(eval, 'error') && ~isfield(model, 'error')
        fprintf('  %s: Acc=%.2f%%, EER=%.2f%%', ...
            modalityNames{m}, eval.accuracy, eval.EER);
        if isfield(model, 'degradation')
            fprintf(', Degradation=%.2f%%', model.degradation);
        end
        fprintf('\n');
    else
        fprintf('  %s: ERROR\n', modalityNames{m});
    end
end

%% Save all results
save('results/all_experiments_optimized.mat', 'allResults', 'allEvaluations', ...
     'comparisonTable', 'cfg');
fprintf('\n✓ All results saved to results/all_experiments_optimized.mat\n');

%% Summary
totalTime = toc;
fprintf('\n════════════════════════════════════════════════════════\n');
fprintf('ALL EXPERIMENTS COMPLETED SUCCESSFULLY!\n');
fprintf('════════════════════════════════════════════════════════\n');
fprintf('Total experiments run: %d\n', totalExperiments);
fprintf('Total execution time: %s\n', format_time(totalTime));
fprintf('Average time per experiment: %.2f seconds\n', totalTime/totalExperiments);

if cfg.useParallel
    fprintf('Parallel processing: ENABLED\n');
else
    fprintf('Parallel processing: DISABLED\n');
end

fprintf('\nGenerated files in results/ folder:\n');
fprintf('  - preprocessed.mat\n');
fprintf('  - features_day1_*.mat (3 files)\n');
fprintf('  - features_day2_*.mat (3 files)\n');
fprintf('  - model_scenarioX_modalityY_optimized.mat (9 files)\n');
fprintf('  - all_experiments_optimized.mat (comprehensive results)\n');
fprintf('\nKey Findings:\n');
fprintf('  → Best Overall: %s (Acc=%.2f%%, EER=%.2f%%)\n', bestAccName, bestAccuracy, bestEER);
fprintf('  → Fastest Training: %s (%.2f seconds)\n', fastestName, fastestTime);
fprintf('  → Most Realistic (Scenario 2) provides cross-day validation\n');
fprintf('  → Test 3 (Combined) provides upper bound on performance\n');
fprintf('════════════════════════════════════════════════════════\n\n');

fprintf('NEXT STEP:\n');
fprintf('Run visualize.m to generate plots\n');

