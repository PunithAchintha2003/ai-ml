function optimize_model()
%% OPTIMIZE_MODEL - Feature selection and hyperparameter tuning
% =========================================================================
% This function optimizes the neural network model through:
%   1. Feature Selection: Using FSCMRMR, ReliefF, or ANOVA F-test
%   2. Feature Count Optimization: Testing k = [5, 10, 15, 20, 30]
%   3. Architecture Search: Testing different hidden layer configurations
%   4. Cross-validation: 4-fold CV for robust evaluation
%
% Outputs:
%   - results/optResults.mat: optimization results
%   - Console output showing best configuration
%
% Reference: [5] Guyon & Elisseeff, 2003 - Feature Extraction: Foundations and Applications
% =========================================================================

    fprintf('Loading feature data...\n');
    load('results/featuresTable.mat', 'allFeatures', 'allLabels', 'featureNames');
    load('results/baseline_model.mat', 'model');
    
    baselineAccuracy = model.testAccuracy;
    fprintf('Baseline test accuracy: %.2f%%\n', baselineAccuracy);
    
    %% Feature Ranking
    fprintf('\n--- STEP 1: Feature Ranking ---\n');
    fprintf('Computing feature importance...\n');
    
    % Try FSCMRMR first, fallback to ReliefF, then ANOVA
    try
        [idx, scores] = fscmrmr(allFeatures, allLabels);
        fprintf('✓ Using FSCMRMR for feature ranking\n');
        method = 'FSCMRMR';
    catch
        try
            [idx, scores] = relieff(allFeatures, allLabels, 10);
            fprintf('✓ Using ReliefF for feature ranking\n');
            method = 'ReliefF';
        catch
            % Use ANOVA F-test as fallback
            fprintf('✓ Using ANOVA F-test for feature ranking\n');
            [idx, scores] = computeANOVARanking(allFeatures, allLabels);
            method = 'ANOVA F-test';
        end
    end
    
    % Display top features
    fprintf('\nTop 10 most discriminative features:\n');
    for i = 1:min(10, length(idx))
        fprintf('  %2d. %s (score: %.4f)\n', i, featureNames{idx(i)}, scores(idx(i)));
    end
    
    %% Feature Count Optimization
    fprintf('\n--- STEP 2: Feature Count Optimization ---\n');
    fprintf('Testing different feature counts with 4-fold CV...\n');
    
    kValues = [5, 10, 15, 20, 30, size(allFeatures, 2)]; % Include "all features"
    kValues = kValues(kValues <= size(allFeatures, 2)); % Filter valid k
    
    cvAccuracies = zeros(length(kValues), 1);
    cvStds = zeros(length(kValues), 1);
    
    rng(42); % For reproducibility
    cv = cvpartition(allLabels, 'KFold', 4);
    
    for k_idx = 1:length(kValues)
        k = kValues(k_idx);
        fprintf('\nTesting k=%d features... ', k);
        
        % Select top k features
        selectedFeatures = allFeatures(:, idx(1:k));
        
        % 4-fold cross-validation
        foldAccuracies = zeros(4, 1);
        for fold = 1:4
            trainIdx = training(cv, fold);
            testIdx = test(cv, fold);
            
            X_train = selectedFeatures(trainIdx, :);
            y_train = allLabels(trainIdx);
            X_test = selectedFeatures(testIdx, :);
            y_test = allLabels(testIdx);
            
            % Standardize
            mu = mean(X_train);
            sigma = std(X_train);
            sigma(sigma == 0) = 1;
            X_train_norm = (X_train - mu) ./ sigma;
            X_test_norm = (X_test - mu) ./ sigma;
            
            % Train simple NN
            net = patternnet([128, 64], 'trainscg');
            net.trainParam.epochs = 200;
            net.trainParam.showWindow = false;
            net.trainParam.showCommandLine = false;
            net.divideParam.trainRatio = 0.85;
            net.divideParam.valRatio = 0.15;
            net.divideParam.testRatio = 0;
            
            % Convert labels
            uniqueUsers = unique(allLabels);
            labelMap = containers.Map(uniqueUsers, 1:length(uniqueUsers));
            y_train_idx = zeros(size(y_train));
            y_test_idx = zeros(size(y_test));
            for i = 1:length(y_train)
                y_train_idx(i) = labelMap(y_train(i));
            end
            for i = 1:length(y_test)
                y_test_idx(i) = labelMap(y_test(i));
            end
            
            % Train
            y_train_onehot = full(ind2vec(y_train_idx'));
            net = train(net, X_train_norm', y_train_onehot);
            
            % Test
            y_pred = net(X_test_norm');
            [~, y_pred_idx] = max(y_pred);
            foldAccuracies(fold) = sum(y_pred_idx' == y_test_idx) / length(y_test_idx) * 100;
        end
        
        cvAccuracies(k_idx) = mean(foldAccuracies);
        cvStds(k_idx) = std(foldAccuracies);
        
        fprintf('CV Accuracy: %.2f%% ± %.2f%%\n', cvAccuracies(k_idx), cvStds(k_idx));
    end
    
    % Find best k
    [bestCVAccuracy, bestK_idx] = max(cvAccuracies);
    bestK = kValues(bestK_idx);
    
    fprintf('\n✓ Best feature count: k=%d (CV Accuracy: %.2f%%)\n', bestK, bestCVAccuracy);
    
    %% Architecture Optimization
    fprintf('\n--- STEP 3: Architecture Optimization ---\n');
    fprintf('Testing different network architectures...\n');
    
    architectures = {[64, 32], [128, 64], [256, 128], [128], [256]};
    archNames = {'[64,32]', '[128,64]', '[256,128]', '[128]', '[256]'};
    archAccuracies = zeros(length(architectures), 1);
    
    % Use best k features
    selectedFeatures = allFeatures(:, idx(1:bestK));
    
    for arch_idx = 1:length(architectures)
        hiddenLayers = architectures{arch_idx};
        fprintf('\nTesting architecture %s... ', archNames{arch_idx});
        
        % 4-fold CV
        foldAccuracies = zeros(4, 1);
        for fold = 1:4
            trainIdx = training(cv, fold);
            testIdx = test(cv, fold);
            
            X_train = selectedFeatures(trainIdx, :);
            y_train = allLabels(trainIdx);
            X_test = selectedFeatures(testIdx, :);
            y_test = allLabels(testIdx);
            
            % Standardize
            mu = mean(X_train);
            sigma = std(X_train);
            sigma(sigma == 0) = 1;
            X_train_norm = (X_train - mu) ./ sigma;
            X_test_norm = (X_test - mu) ./ sigma;
            
            % Train NN with this architecture
            net = patternnet(hiddenLayers, 'trainscg');
            net.trainParam.epochs = 200;
            net.trainParam.showWindow = false;
            net.trainParam.showCommandLine = false;
            net.divideParam.trainRatio = 0.85;
            net.divideParam.valRatio = 0.15;
            net.divideParam.testRatio = 0;
            
            % Convert labels
            uniqueUsers = unique(allLabels);
            labelMap = containers.Map(uniqueUsers, 1:length(uniqueUsers));
            y_train_idx = zeros(size(y_train));
            y_test_idx = zeros(size(y_test));
            for i = 1:length(y_train)
                y_train_idx(i) = labelMap(y_train(i));
            end
            for i = 1:length(y_test)
                y_test_idx(i) = labelMap(y_test(i));
            end
            
            % Train
            y_train_onehot = full(ind2vec(y_train_idx'));
            net = train(net, X_train_norm', y_train_onehot);
            
            % Test
            y_pred = net(X_test_norm');
            [~, y_pred_idx] = max(y_pred);
            foldAccuracies(fold) = sum(y_pred_idx' == y_test_idx) / length(y_test_idx) * 100;
        end
        
        archAccuracies(arch_idx) = mean(foldAccuracies);
        fprintf('CV Accuracy: %.2f%%\n', archAccuracies(arch_idx));
    end
    
    % Find best architecture
    [bestArchAccuracy, bestArch_idx] = max(archAccuracies);
    bestArchitecture = architectures{bestArch_idx};
    bestArchName = archNames{bestArch_idx};
    
    fprintf('\n✓ Best architecture: %s (CV Accuracy: %.2f%%)\n', bestArchName, bestArchAccuracy);
    
    %% Save Optimization Results
    optResults = struct();
    optResults.featureRankingMethod = method;
    optResults.featureIndices = idx;
    optResults.featureScores = scores;
    optResults.topFeatures = featureNames(idx(1:min(10, length(idx))));
    optResults.kValues = kValues;
    optResults.cvAccuracies = cvAccuracies;
    optResults.cvStds = cvStds;
    optResults.bestK = bestK;
    optResults.bestCVAccuracy = bestCVAccuracy;
    optResults.architectures = archNames;
    optResults.archAccuracies = archAccuracies;
    optResults.bestArchitecture = bestArchitecture;
    optResults.bestArchName = bestArchName;
    optResults.bestArchAccuracy = bestArchAccuracy;
    optResults.baselineAccuracy = baselineAccuracy;
    optResults.improvement = bestArchAccuracy - baselineAccuracy;
    
    save('results/optResults.mat', 'optResults');
    
    %% Summary
    fprintf('\n========================================\n');
    fprintf('OPTIMIZATION SUMMARY\n');
    fprintf('========================================\n');
    fprintf('Feature Ranking Method: %s\n', method);
    fprintf('Best Feature Count: k=%d\n', bestK);
    fprintf('Best Architecture: %s\n', bestArchName);
    fprintf('Baseline Accuracy: %.2f%%\n', baselineAccuracy);
    fprintf('Optimized Accuracy: %.2f%%\n', bestArchAccuracy);
    fprintf('Improvement: %+.2f%%\n', optResults.improvement);
    fprintf('========================================\n');
    fprintf('\nResults saved to results/optResults.mat\n');
end

function [idx, scores] = computeANOVARanking(X, y)
%% COMPUTE_ANOVA_RANKING - Fallback feature ranking using ANOVA F-test
% =========================================================================
    numFeatures = size(X, 2);
    scores = zeros(numFeatures, 1);
    
    uniqueClasses = unique(y);
    
    for f = 1:numFeatures
        % Get feature values for each class
        groups = cell(length(uniqueClasses), 1);
        for c = 1:length(uniqueClasses)
            groups{c} = X(y == uniqueClasses(c), f);
        end
        
        % Compute F-statistic
        try
            [~, ~, stats] = anova1(X(:, f), y, 'off');
            scores(f) = stats.F;
        catch
            scores(f) = 0;
        end
    end
    
    % Rank features by F-score (higher is better)
    [scores, idx] = sort(scores, 'descend');
end

