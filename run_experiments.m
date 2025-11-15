%% RUN_EXPERIMENTS - Complete Experimental Setup for Behavioral Biometrics
% =========================================================================
% Course: PUSL3123 - AI and Machine Learning
% Project: Behavioral Biometrics User Authentication
% =========================================================================
%
% This script implements the complete experimental setup with:
%   - 3 Testing Scenarios
%   - 3 Modalities (Accelerometer, Gyroscope, Combined)
%   - Comprehensive evaluation metrics (FAR, FRR, EER)
%
% Experimental Setup:
%   Test 1: Train and test on Day 1 data (same day performance)
%   Test 2: Train on Day 1, test on Day 2 (MOST REALISTIC)
%   Test 3: Combined data with 70/30 split (maximum performance)
%
% Modalities:
%   1. Accelerometer only
%   2. Gyroscope only  
%   3. Combined (Accelerometer + Gyroscope)
%
% Output:
%   - Results for all 9 combinations (3 scenarios × 3 modalities)
%   - Comparative performance tables
%   - Saved results in results/ folder
%
% Total Experiments: 3 scenarios × 3 modalities = 9 experiments
% =========================================================================

clear all; close all; clc;

fprintf('============================================================\n');
fprintf('BEHAVIORAL BIOMETRICS - COMPLETE EXPERIMENTAL SETUP\n');
fprintf('============================================================\n\n');

% Create results directory if it doesn't exist
if ~exist('results', 'dir')
    mkdir('results');
    fprintf('Created results/ directory\n');
end

% Start timer
tic;

%% STEP 1: Preprocess Data
fprintf('\n[STEP 1/4] Preprocessing sensor data...\n');
fprintf('------------------------------------------------------------\n');
preprocess_data();
fprintf('✓ Preprocessing complete\n');

%% STEP 2: Extract Features
fprintf('\n[STEP 2/4] Extracting features for all modalities...\n');
fprintf('------------------------------------------------------------\n');
extract_features();
fprintf('✓ Feature extraction complete\n');

%% STEP 3: Run All Scenarios and Modalities
fprintf('\n[STEP 3/4] Running experiments (3 scenarios × 3 modalities)...\n');
fprintf('------------------------------------------------------------\n');

scenarios = {'scenario1', 'scenario2', 'scenario3'};
scenarioNames = {'Test 1: Day 1 Train+Test', ...
                 'Test 2: Day 1 Train, Day 2 Test (REALISTIC)', ...
                 'Test 3: Combined 70/30'};
modalities = {'accel', 'gyro', 'combined'};
modalityNames = {'Accelerometer Only', 'Gyroscope Only', 'Combined Sensors'};

% Initialize result storage
allResults = struct();
allEvaluations = struct();

experimentCount = 0;
totalExperiments = length(scenarios) * length(modalities);

for s = 1:length(scenarios)
    for m = 1:length(modalities)
        experimentCount = experimentCount + 1;
        
        fprintf('\n════════════════════════════════════════════════════════\n');
        fprintf('EXPERIMENT %d/%d\n', experimentCount, totalExperiments);
        fprintf('Scenario: %s\n', scenarioNames{s});
        fprintf('Modality: %s\n', modalityNames{m});
        fprintf('════════════════════════════════════════════════════════\n');
        
        % Run scenario
        switch s
            case 1
                model = train_test_scenario1(modalities{m});
            case 2
                model = train_test_scenario2(modalities{m});
            case 3
                model = train_test_scenario3(modalities{m});
        end
        
        % Evaluate model
        evaluation = evaluate_scenarios(model);
        
        % Store results
        resultName = sprintf('%s_%s', scenarios{s}, modalities{m});
        allResults.(resultName) = model;
        allEvaluations.(resultName) = evaluation;
        
        % Save individual result
        save(sprintf('results/model_%s_%s.mat', scenarios{s}, modalities{m}), 'model', 'evaluation');
        
        fprintf('\n✓ Experiment %d/%d complete\n', experimentCount, totalExperiments);
    end
end

fprintf('\n✓ All experiments completed!\n');

%% STEP 4: Generate Comparison Tables
fprintf('\n[STEP 4/4] Generating comparison tables...\n');
fprintf('------------------------------------------------------------\n');

% Create comprehensive comparison table
comparisonTable = cell(totalExperiments + 1, 7);
comparisonTable(1, :) = {'Scenario', 'Modality', 'Train Acc (%)', 'Test Acc (%)', 'EER (%)', 'Avg FAR (%)', 'Avg FRR (%)'};

row = 2;
for s = 1:length(scenarios)
    for m = 1:length(modalities)
        resultName = sprintf('%s_%s', scenarios{s}, modalities{m});
        model = allResults.(resultName);
        eval = allEvaluations.(resultName);
        
        comparisonTable{row, 1} = scenarioNames{s};
        comparisonTable{row, 2} = modalityNames{m};
        comparisonTable{row, 3} = sprintf('%.2f', model.trainAccuracy);
        comparisonTable{row, 4} = sprintf('%.2f', model.testAccuracy);
        comparisonTable{row, 5} = sprintf('%.2f', eval.EER);
        comparisonTable{row, 6} = sprintf('%.2f', mean(eval.perUserFAR));
        comparisonTable{row, 7} = sprintf('%.2f', mean(eval.perUserFRR));
        
        row = row + 1;
    end
end

% Display comparison table
fprintf('\n════════════════════════════════════════════════════════════════════════════════\n');
fprintf('COMPREHENSIVE RESULTS COMPARISON (All Scenarios × All Modalities)\n');
fprintf('════════════════════════════════════════════════════════════════════════════════\n');
fprintf('%-40s | %-20s | %10s | %10s | %8s | %9s | %9s\n', ...
    'Scenario', 'Modality', 'Train Acc', 'Test Acc', 'EER', 'Avg FAR', 'Avg FRR');
fprintf('────────────────────────────────────────────────────────────────────────────────\n');

for i = 2:size(comparisonTable, 1)
    fprintf('%-40s | %-20s | %10s | %10s | %8s | %9s | %9s\n', ...
        comparisonTable{i, 1}, comparisonTable{i, 2}, comparisonTable{i, 3}, ...
        comparisonTable{i, 4}, comparisonTable{i, 5}, comparisonTable{i, 6}, comparisonTable{i, 7});
end

fprintf('════════════════════════════════════════════════════════════════════════════════\n\n');

%% Analysis by Scenario
fprintf('\n--- Analysis by Scenario ---\n');
for s = 1:length(scenarios)
    fprintf('\n%s:\n', scenarioNames{s});
    for m = 1:length(modalities)
        resultName = sprintf('%s_%s', scenarios{s}, modalities{m});
        eval = allEvaluations.(resultName);
        fprintf('  %s: Acc=%.2f%%, EER=%.2f%%\n', ...
            modalityNames{m}, eval.accuracy, eval.EER);
    end
end

%% Analysis by Modality
fprintf('\n--- Analysis by Modality ---\n');
for m = 1:length(modalities)
    fprintf('\n%s:\n', modalityNames{m});
    for s = 1:length(scenarios)
        resultName = sprintf('%s_%s', scenarios{s}, modalities{m});
        eval = allEvaluations.(resultName);
        fprintf('  %s: Acc=%.2f%%, EER=%.2f%%\n', ...
            scenarioNames{s}, eval.accuracy, eval.EER);
    end
end

%% Find Best Configurations
fprintf('\n--- Best Performing Configurations ---\n');

% Find best overall accuracy
bestAccuracy = 0;
bestAccName = '';
for s = 1:length(scenarios)
    for m = 1:length(modalities)
        resultName = sprintf('%s_%s', scenarios{s}, modalities{m});
        eval = allEvaluations.(resultName);
        if eval.accuracy > bestAccuracy
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
        resultName = sprintf('%s_%s', scenarios{s}, modalities{m});
        eval = allEvaluations.(resultName);
        if eval.EER < bestEER
            bestEER = eval.EER;
            bestEERName = sprintf('%s + %s', scenarioNames{s}, modalityNames{m});
        end
    end
end
fprintf('Best EER: %.2f%% (%s)\n', bestEER, bestEERName);

% Find most realistic scenario performance
fprintf('\nMost Realistic Scenario (Test 2: Day 1→Day 2):\n');
for m = 1:length(modalities)
    resultName = sprintf('scenario2_%s', modalities{m});
    eval = allEvaluations.(resultName);
    model = allResults.(resultName);
    fprintf('  %s: Acc=%.2f%%, EER=%.2f%%', modalityNames{m}, eval.accuracy, eval.EER);
    if isfield(model, 'degradation')
        fprintf(', Degradation=%.2f%%', model.degradation);
    end
    fprintf('\n');
end

%% Save all results
save('results/all_experiments.mat', 'allResults', 'allEvaluations', 'comparisonTable');
fprintf('\n✓ All results saved to results/all_experiments.mat\n');

%% Summary
totalTime = toc;
fprintf('\n════════════════════════════════════════════════════════\n');
fprintf('ALL EXPERIMENTS COMPLETED SUCCESSFULLY!\n');
fprintf('════════════════════════════════════════════════════════\n');
fprintf('Total experiments run: %d\n', totalExperiments);
fprintf('Total execution time: %.2f seconds (%.2f minutes)\n', totalTime, totalTime/60);
fprintf('\nGenerated files in results/ folder:\n');
fprintf('  - preprocessed.mat\n');
fprintf('  - features_day1_accel.mat, features_day1_gyro.mat, features_day1_combined.mat\n');
fprintf('  - features_day2_accel.mat, features_day2_gyro.mat, features_day2_combined.mat\n');
fprintf('  - model_scenarioX_modalityY.mat (9 files)\n');
fprintf('  - all_experiments.mat (comprehensive results)\n');
fprintf('\nKey Findings:\n');
fprintf('  → Best Overall: %s (Acc=%.2f%%, EER=%.2f%%)\n', bestAccName, bestAccuracy, bestEER);
fprintf('  → Most Realistic (Scenario 2) provides cross-day validation\n');
fprintf('  → Test 3 (Combined) provides upper bound on performance\n');
fprintf('════════════════════════════════════════════════════════\n\n');

fprintf('NEXT STEPS:\n');
fprintf('1. Review comparison table above\n');
fprintf('2. Run visualize_results.m to generate plots\n');
fprintf('3. Include results in your report with discussion\n');
fprintf('4. Explain differences between scenarios and modalities\n\n');
