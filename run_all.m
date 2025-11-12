%% RUN_ALL - Main Script for Acceleration-Based User Authentication
% =========================================================================
% Course: PUSL3123 - AI and Machine Learning
% Project: Acceleration-Based Continuous User Authentication using Neural Networks
% =========================================================================
%
% This script orchestrates the entire pipeline:
%   1. Data Preprocessing
%   2. Feature Extraction
%   3. Variability Analysis
%   4. Neural Network Training
%   5. Model Evaluation
%   6. Model Optimization
%
% Requirements:
%   - MATLAB R2023b or newer
%   - Deep Learning Toolbox
%   - Statistics and Machine Learning Toolbox
%   - Signal Processing Toolbox
%
% Author: AI & ML Coursework
% Date: November 2025
% =========================================================================

clear all; close all; clc;

fprintf('============================================================\n');
fprintf('Acceleration-Based User Authentication - Neural Networks\n');
fprintf('============================================================\n\n');

% Create results directory if it doesn't exist
if ~exist('results', 'dir')
    mkdir('results');
    fprintf('Created results/ directory\n');
end

% Start timer
tic;

%% STEP 1: Preprocess Data
fprintf('\n[STEP 1/6] Preprocessing accelerometer data...\n');
fprintf('------------------------------------------------------------\n');
preprocess_data();
fprintf('✓ Preprocessing complete. Data saved to results/preprocessed.mat\n');

%% STEP 2: Extract Features
fprintf('\n[STEP 2/6] Extracting features from signals...\n');
fprintf('------------------------------------------------------------\n');
extract_features();
fprintf('✓ Feature extraction complete. Features saved to results/featuresTable.mat\n');

%% STEP 3: Variability Analysis
fprintf('\n[STEP 3/6] Analyzing user variability...\n');
fprintf('------------------------------------------------------------\n');
helpers_variability_plot();
fprintf('✓ Variability analysis complete. Plots saved to results/\n');

%% STEP 4: Train Neural Network
fprintf('\n[STEP 4/6] Training baseline neural network model...\n');
fprintf('------------------------------------------------------------\n');
train_nn();
fprintf('✓ Training complete. Model saved to results/baseline_model.mat\n');

%% STEP 5: Evaluate Model
fprintf('\n[STEP 5/6] Evaluating model performance...\n');
fprintf('------------------------------------------------------------\n');
evaluate_model();
fprintf('✓ Evaluation complete. Results saved to results/evalResults.mat\n');

%% STEP 6: Optimize Model
fprintf('\n[STEP 6/6] Optimizing model (feature selection + tuning)...\n');
fprintf('------------------------------------------------------------\n');
optimize_model();
fprintf('✓ Optimization complete. Results saved to results/optResults.mat\n');

%% Summary
totalTime = toc;
fprintf('\n============================================================\n');
fprintf('ALL STEPS COMPLETED SUCCESSFULLY!\n');
fprintf('============================================================\n');
fprintf('Total execution time: %.2f seconds (%.2f minutes)\n', totalTime, totalTime/60);
fprintf('\nGenerated outputs in results/ folder:\n');
fprintf('  - preprocessed.mat\n');
fprintf('  - featuresTable.mat\n');
fprintf('  - baseline_model.mat\n');
fprintf('  - evalResults.mat\n');
fprintf('  - optResults.mat\n');
fprintf('  - PCA_scatter.png\n');
fprintf('  - feature_boxplots.png\n');
fprintf('  - confusion_matrix.png\n');
fprintf('  - FAR_FRR_curve.png\n');
fprintf('  - TAR_vs_FAR.png\n');
fprintf('============================================================\n');

